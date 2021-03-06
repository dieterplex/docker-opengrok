# docker-opengrok

The one-liner to spin up a code search engine

[OpenGrok](http://opengrok.github.io/OpenGrok/) is a code search engine 
made by Sun (and now Oracle). 

It provides similar functions to [LXR](http://lxr.linux.no/) but much more. 
This project encapsulated OpenGrok into a docker container, allowing you 
to start an instance of OpenGrok by one command.

## Usage

To start the OpenGrok, simply run:

```sh
docker run --privileged -d -v SRC_PATH:/opengrok/src -v DATA_PATH:/opengrok/data -p [public port]:8080 dieterplex/docker-opengrok
```

Put the source codes under SRC_PATH/ on host.
(Optional)Put the indexed data under DATA_PATH on host.

It may take a while for the indexer to finish the first-time indexing, after
that, the search engine is available at `http://host:[public port]/source/`.

## Note

The project supports dynamic index updating through `inotifywait` recursively on the source folder. 
This can be disabled with the environment variable `INOTIFY_NOT_RECURSIVE` at runtime.
Also, if you have more than 8192 files to watch, 
it has been modified for you to increase the amount of inotify watches allowed per user `(/proc/sys/fs/inotify/max_user_watches)` on your host system.

NOTE: `touch` doesn't trigger inotify. You should add, delete or modify the content of some source file to make it happen.

NOTE2: this image based on Ubuntu:16.04 and tomcat8

NOTE3: this dockerfile is created for testing latest opengrok build from source
