#--------------------------------------------------------------------------------------------------
# gradle-springboot-rhel7
#--------------------------------------------------------------------------------------------------

FROM rhel7.4 

#--------------------------------------------------------------------------------------------------
# software versions used inside the builder
#--------------------------------------------------------------------------------------------------

ENV GRADLE_VERSION=4.6
ENV OPENJDK_VERSION=1.8.0

#--------------------------------------------------------------------------------------------------
# Docker Image Metadata
#--------------------------------------------------------------------------------------------------

LABEL io.k8s.description="Platform for building SpringBoot apps with Gradle" \
      io.k8s.display-name="Springboot Builder with Gradle" \
      io.openshift.tags="builder,java,gradle,springboot" \
      io.openshift.expose-services="8080:http" \
      maintainer="TAS@sabre.com"

#--------------------------------------------------------------------------------------------------
# Install the required software 
#--------------------------------------------------------------------------------------------------

RUN INSTALL_PKGS="wget unzip java-${OPENJDK_VERSION}-openjdk java-${OPENJDK_VERSION}-openjdk-devel" && \
    yum install -y $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum clean all -y

RUN wget https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip && \
    mkdir /opt/gradle && \
    unzip -d /opt/gradle gradle-${GRADLE_VERSION}-bin.zip && \
    rm gradle-${GRADLE_VERSION}-bin.zip && \
    ln -s /opt/gradle/gradle-${GRADLE_VERSION}/bin/gradle /usr/local/bin/gradle

#--------------------------------------------------------------------------------------------------
# The location of the S2I. Although this is defined in in the base image, it's repeated here to
# make it clear why the following COPY operation is happening.
#--------------------------------------------------------------------------------------------------

LABEL io.openshift.s2i.scripts-url=image:///usr/local/s2i

#--------------------------------------------------------------------------------------------------
# Copy the S2I scripts from ./s2i/bin/ to /usr/local/s2i when making the builder image
#--------------------------------------------------------------------------------------------------

COPY ./s2i/bin/ /usr/local/s2i

#--------------------------------------------------------------------------------------------------
# Drop the root user and make the content of /opt/app-root owned by user 1001
#--------------------------------------------------------------------------------------------------

RUN mkdir -p /opt/app-root && \
    chown -R 1001:1001 /opt/app-root

#--------------------------------------------------------------------------------------------------
# Set the default user for the image, the user itself was created in the base image
#--------------------------------------------------------------------------------------------------

USER 1001

#--------------------------------------------------------------------------------------------------
# Specify the ports the final image will expose
#--------------------------------------------------------------------------------------------------

EXPOSE 8080

#--------------------------------------------------------------------------------------------------
# Set the default CMD to print the usage of the image, if somebody does docker run
#--------------------------------------------------------------------------------------------------

CMD ["/usr/local/s2i/usage"]
