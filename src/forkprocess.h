#ifndef FORKPROCESS_H
#define FORKPROCESS_H

#include <QObject>
#include <QThread>
#include <sys/types.h>
#include <unistd.h>

class ForkReaderThread : public QThread
{
	Q_OBJECT
	void run() Q_DECL_OVERRIDE;
public:
	void setFd(int val);
signals:
	void lineReady(const QString &str);
	void started(void);
	void stopped(void);
private:
	int fd;
};

class ForkProcess : public QObject
{
	Q_OBJECT
public:
	explicit ForkProcess(QObject *parent = 0);
	Q_INVOKABLE bool spawnProcess();
	Q_INVOKABLE void killProcess();

	Q_PROPERTY(QString port READ getPort WRITE setPort)
	Q_PROPERTY(bool symlinks READ getSymlinks WRITE setSymlinks)
	Q_PROPERTY(QString docroot READ getDocroot WRITE setDocroot)
	Q_PROPERTY(QString logfile READ getLogfile WRITE setLogfile)

	QString getPort() const;
	bool getSymlinks() const;
	QString getDocroot() const;
	QString getLogfile() const;

	void setPort(QString val);
	void setSymlinks(bool val);
	void setDocroot(QString val);
	void setLogfile(QString val);
signals:
	void lineReady(const QString &str);
	void started(void);
	void stopped(void);

public slots:
	void gotLine(const QString &str);
	void gotStarted(void);
	void gotStopped(void);

private:
	void makeEmpty(void);

	pid_t child;
	/* A pipe to grab a line from the child */
	int fd[2];
	QString port;
	bool symlinks;
	QString docroot;
	QString logfile;
	ForkReaderThread frt;
};

#endif // FORKPROCESS_H
