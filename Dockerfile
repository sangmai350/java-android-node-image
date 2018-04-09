FROM sangmai350/java-android-node-image

### Android SDK

ENV ANDROID_HOME /opt/android
ENV REPO_OS_OVERRIDE linux
ENV PATH $PATH:$ANDROID_HOME/tools/bin
ENV JAVA_HOME="/opt/java" \
    JAVA_VERSION="8u131" \
    JAVA_BUILD="b11" \
    JAVA_VERSION_HASH="d54c1d3a095b4ff2b6607d096fa80163" \
    NODE_HOME="/opt/node" \
    NODE_VERSION="8.4.0"

ENV PATH="$PATH:$JAVA_HOME/bin:$NODE_HOME/bin"

RUN set -ex && \
    mkdir -p $ANDROID_HOME && \
    curl -s -L -o $ANDROID_HOME/sdk-tools-linux.zip https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip && \
    unzip -q $ANDROID_HOME/sdk-tools-linux.zip -d $ANDROID_HOME && \
    rm $ANDROID_HOME/sdk-tools-linux.zip && \
    mkdir -p /root/.android/ && \
    touch /root/.android/androidtools.cfg && \
    touch /root/.android/repositories.cfg

ARG SDKM_ARGS=
RUN yes | sdkmanager --licenses $SDKM_ARGS && \
    sdkmanager $SDKM_ARGS "platforms;android-26" && \
    sdkmanager $SDKM_ARGS "build-tools;26.0.3" && \
    sdkmanager $SDKM_ARGS "platform-tools" && \
    sdkmanager $SDKM_ARGS "extras;google;google_play_services" && \
    sdkmanager $SDKM_ARGS "extras;google;m2repository" && \
    sdkmanager $SDKM_ARGS "extras;android;m2repository"
ENV PATH $PATH:$ANDROID_HOME/build-tools/26.0.3:$ANDROID_HOME/platform-tools

### Gradle

ENV GRADLE_VERSION 4.1
ENV GRADLE_HOME /opt/gradle-$GRADLE_VERSION
ENV GRADLE_USER_HOME /gradle-user-home
RUN set -ex && \
    curl -s -L -o /opt/gradle-${GRADLE_VERSION}-bin.zip https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip && \
    unzip -q /opt/gradle-${GRADLE_VERSION}-bin.zip -d /opt && \
    ln -s "${GRADLE_HOME}/bin/gradle" /usr/local/bin/gradle

### java
RUN wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/$JAVA_VERSION-$JAVA_BUILD/$JAVA_VERSION_HASH/jdk-$JAVA_VERSION-linux-x64.tar.gz" -O /tmp/java.tar.gz
RUN tar -zxvf /tmp/java.tar.gz -C /opt
RUN mv /opt/jdk* $JAVA_HOME

### node
RUN wget "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" -O /tmp/node.tar.xz
RUN tar xf /tmp/node.tar.xz -C /opt
RUN mv /opt/node-* $NODE_HOME
RUN npm install yarn -g
RUN cd $(npm root -g)/npm && npm install fs-extra && sed -i -e s/graceful-fs/fs-extra/ -e s/fs.rename/fs.move/ ./lib/utils/rename.js
