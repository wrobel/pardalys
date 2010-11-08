VERSION=0.0.8

pardalys-$(VERSION).tar.bz2:
	tar cvjf pardalys-$(VERSION).tar.bz2 pardalys --exclude=".git" --exclude=".svn" --exclude="config.yml"

pardalys-$(VERSION).tar.gz:
	tar cvzf pardalys-$(VERSION).tar.gz pardalys --exclude=".git" --exclude=".svn" --exclude="config.yml"

.PHONY:dist
dist: pardalys-$(VERSION).tar.bz2

.PHONY:release
release: pardalys-$(VERSION).tar.bz2 pardalys-$(VERSION).tar.gz
	git tag -m "Release of pardalys-$(VERSION)" pardalys-$(VERSION)
	scp pardalys-$(VERSION).tar.bz2 www:~/de/pardus/files/downloads/
	scp pardalys-$(VERSION).tar.gz www:~/de/pardus/files/downloads/

.PHONY:clean
clean:
	rm -rf *.tar.bz2
