#include "forkprocess.h"
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/prctl.h>
#include <poll.h>
#include <signal.h>
#include <fcntl.h>
#include <QString>
#include <QStringList>

ForkProcess::ForkProcess(QObject *parent) :
	QObject(parent)
{
	this->makeEmpty();
	/* connect some signals */
	QObject::connect(&(this->frt), &ForkReaderThread::lineReady, this, &ForkProcess::gotLine);
	QObject::connect(&(this->frt), &ForkReaderThread::started, this, &ForkProcess::gotStarted);
	QObject::connect(&(this->frt), &ForkReaderThread::stopped, this, &ForkProcess::gotStopped);
}

void ForkProcess::makeEmpty(void) {
	this->child = -1;
	this->fd[0] = -1;
	this->fd[1] = -1;
	this->frt.setFd(-1);
}

bool ForkProcess::spawnProcess() {
	int ret;
	/* save the parent pid: we might need this
	 * if the parent process dies before the prctl()
	 * call */
	pid_t parent_pid = getpid();
	if (this->child >= 0) {
		return true;
	}
	errno = 0;
	ret = pipe(this->fd);
	if (ret == -1) {
		perror("pipe");
		return false;
	}
	errno = 0;
	this->child = fork();
	if (this->child == -1) {
		perror("fork");
		fputs("omgwtfbbq\n", stderr);
		close(fd[0]);
		close(fd[1]);
		return false;
	}
	if (this->child == 0) {
		QStringList args;
		QString port_arg (this->port);
		QString docroot_arg (this->docroot);
		QString logfile_arg (this->logfile);
		/* kill the child when our app dies */
		errno = 0;
		if (prctl(PR_SET_PDEATHSIG, SIGTERM) == -1) {
			perror("prctl");
			exit(1);
		}
		/* if we were re-parented before prctl,
		 * commit seppuku */
		if (getppid() != parent_pid) {
			fputs("re-parented before setting deathsig!", stderr);
			exit(1);
		}
		port_arg.prepend("-p");
		docroot_arg.prepend("-r");
		logfile_arg.prepend("-o");
		args.append(QString("/usr/libexec/harbour-saildotmekdotlu/mekdotlu"));
		args.append(QString("-C"));
		args.append(port_arg);
		args.append(docroot_arg);
		args.append(logfile_arg);
		if (this->symlinks) {
			args.append(QString("-f"));
		}
		/* close the parent side of the pipe */
		close(this->fd[0]);
		{
			/* allocate enough for a NULL pointer at the end of
			 * the argument list */
			char **argv = (char **) malloc((args.size() + 1) * sizeof(char *));
			fprintf(stderr, "args.size(): %d\n", args.size());
			for (int i = 0; i < args.size(); i += 1) {
				argv[i] = strdup(args.at(i).toUtf8().constData());
				fprintf(stderr, "argv[%d]: %s\n", i, argv[i]);
			}
			argv[args.size()] = NULL;
			/* switch our stdout */
			close(STDOUT_FILENO);
			errno = 0;
			if (dup(this->fd[1]) == -1) {
				perror("dup");
				exit(1);
			}
			close(this->fd[1]);
			/* fire away */
			exit(execv(argv[0], argv));
		}
	} else {
		/* close the child side of the pipe */
		close(this->fd[1]);
		/* spawn dat freaking thread yo */
		this->frt.setParent(this);
		this->frt.setObjectName(QString("ForkReaderThread"));
		this->frt.setFd(this->fd[0]);
		this->frt.start();
		return true;
	}
}

void ForkProcess::killProcess() {
	if (this->child == -1) {
		return;
	}
	kill(this->child, SIGINT);
	this->makeEmpty();
}

void ForkProcess::gotLine(const QString &str) {
	fprintf(
		stderr,
		"%s(): %s\n",
		__FUNCTION__,
		str.toUtf8().constData()
	);
	emit lineReady(str);
}

void ForkProcess::gotStarted(void) {
	emit started();
}

void ForkProcess::gotStopped(void) {
	emit stopped();
	this->makeEmpty();
}

void ForkReaderThread::setFd(int val) {
	this->fd = val;
}

#define FRT_BUFSIZE 1024
void ForkReaderThread::run() {
	QString *line = new QString("");
	fprintf(stderr, "Entered %s()\n", __FUNCTION__);
	char buf[FRT_BUFSIZE];
	bool killify = false, alive = true;
	struct pollfd pfd;
	ssize_t ret;
	if (this->fd == -1) {
		return;
	}
	pfd.fd = this->fd;
	pfd.events = POLLIN;
	emit started();
	for (errno = 0; alive && (ret = read(pfd.fd, buf, sizeof(buf) - 1)) >= 0; errno = 0) {
		do {
			if (ret > 0) {
				char *nlpos = NULL;
				buf[ret] = '\0';
				nlpos = strchr(buf, '\n');
				if (nlpos != NULL) {
					char *cpy;
					*nlpos = '\0';
					cpy = strdup(buf);
					line->append(cpy);
					free(cpy);
					/* emit a line signal */
					emit lineReady(*line);
					/* start over */
					line = new QString("");
					nlpos += 1;
					ret = ret - strlen(buf) - 1;
					if (ret > 0) {
						memmove(buf, nlpos, ret);
						continue;
					}
				} else {
					line->append(buf);
				}
				killify = false;
			} else {
				int pollret;
				if ((pollret = poll(&pfd, 1, 5000)) < 0) {
					/* börken pipe */
					alive = false;
					break;
				}
				if (killify) {
					/* we have a death */
					alive = false;
					break;
				}
				if (pollret == 1) {
					killify = true;
				} else {
					killify = false;
				}
			}
			break;
		} while (true);
	}
	if (ret == -1) {
		perror("read");
	}
	/* if we still have something on the line, emit it */
	if (line->length() > 0) {
		emit lineReady(*line);
	} else {
		/* clean up if necessary */
		delete line;
	}
	/* don't leave zombies */
	::wait(NULL);
	emit stopped();
}

QString ForkProcess::getPort() const {
	return this->port;
}

bool ForkProcess::getSymlinks() const {
	return this->symlinks;
}

QString ForkProcess::getDocroot() const {
	return this->docroot;
}

QString ForkProcess::getLogfile() const {
	return this->logfile;
}

void ForkProcess::setPort(QString val) {
	this->port = val;
}

void ForkProcess::setSymlinks(bool val) {
	this->symlinks = val;
}

void ForkProcess::setDocroot(QString val) {
	this->docroot = val;
}

void ForkProcess::setLogfile(QString val) {
	this->logfile = val;
}
