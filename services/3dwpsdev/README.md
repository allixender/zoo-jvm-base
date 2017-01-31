## A Simple Java Native Interface (JNI) example in Java and Scala

http://hohonuuli.blogspot.co.nz/2013/08/a-simple-java-native-interface-jni.html

```bash
# Java class, compile, create header file from class-file
javac Sample1.java
javah Sample1

# Scala similarly, compile Scala class, create header file from compiled Scala class file, but include Scala libs
export SCALA_CP=$SCALA_LIB_HOME/scala-library.jar:$SCALA_LIB_HOME/scala-reflect.jar

scalac Sample1.scala
javah -cp $SCALA_CP:. Sample1

# generated Header file is identical

# compile the native lib, important -> needs to have lib-prefix, include JVM and generated header file paths as Includes
g++ -shared -fPIC -Wall -O3 -I/usr/include -I$JAVA_HOME/include/linux -I$JAVA_HOME/include -I../java Sample1.cpp -o libSample1.so

# make compiled shared lib available for java library path
export LD_LIBRARY_PATH=~/dev/build/3dwpsdev/src/main/cpp

# run java class, calls the .so
java -Djava.library.path=$LD_LIBRARY_PATH -cp . Sample1

# run Scala class, calls the .so, needs Scala libs in class path
java -Djava.library.path=$LD_LIBRARY_PATH -cp $SCALA_CP:. Sample1
```

## Other places to watch

https://github.com/jodersky/akka-serial/blob/master/Documentation/developer.md

https://github.com/jodersky/sbt-jni
