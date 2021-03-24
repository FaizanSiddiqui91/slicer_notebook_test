FROM lassoan/slicer-notebook:2020-05-15-89b6bb5
COPY --chown=sliceruser . ${HOME}/nb
WORKDIR ${HOME}/nb


################################################################################
# launch jupyter
# Prevent apt-get from prompting for keyboard choice
#  https://superuser.com/questions/1356914/how-to-install-xserver-xorg-in-unattended-mode





FROM debian:bullseye-20200422-slim

################################################################################


################################################################################


################################################################################

################################################################################

################################################################################
# set up user
ENV NB_USER sliceruser
ENV NB_UID 1000
ENV HOME /home/${NB_USER}

RUN adduser --disabled-password \
            --gecos "Default user" \
            --uid ${NB_UID} \
            ${NB_USER}



################################################################################
# Download and unpack Slicer

ARG SLICER_ARCHIVE=Slicer-4.13.0-2020-12-20-linux-amd64
ARG SLICER_DOWNLOAD_URL=http://slicer.kitware.com/midas3/api/rest?method=midas.bitstream.download&name=Slicer-4.13.0-2020-12-20-linux-amd64.tar.gz&checksum=eeb9ba596f3d5ff20265e7d9de9392fe

# Use local package:
#ADD $SLICER_ARCHIVE.tar.gz ${HOME}/

# Download package:
RUN curl -OJL "$SLICER_DOWNLOAD_URL" && \
    tar xzf $SLICER_ARCHIVE.tar.gz && \
    rm $SLICER_ARCHIVE.tar.gz && \
    mv $SLICER_ARCHIVE Slicer

################################################################################
# these go after installs to avoid trivial invalidation
ENV VNCPORT=49053
ENV JUPYTERPORT=8888
ENV DISPLAY=:10

COPY xorg.conf .

# Prevent git error:
#   fatal: unable to access 'https://github.com/novnc/websockify/': server certificate verification failed. CAfile: none CRLfile: none
RUN apt-get -y -q install git && \
    apt-get install --reinstall ca-certificates

################################################################################
# Set up remote desktop access - step 1/2

# Build rebind.so (required by websockify)
RUN set -x && \
    apt-get install -y build-essential --no-install-recommends && \
    mkdir src && \
    cd src && \
    git clone https://github.com/novnc/websockify websockify && \
    cd websockify && \
    make && \
    cp rebind.so /usr/lib/ && \
    cd .. && \
    rm -rf websockify && \
    cd .. && \
    rmdir src && \
    apt-get purge -y --auto-remove build-essential

# Set up launcher for websockify
# (websockify must run in  Slicer's Python environment)
COPY websockify ./Slicer/bin/
RUN chmod +x ${HOME}/Slicer/bin/websockify

################################################################################
# Need to run Slicer as non-root because
# - mybinder requirement
# - chrome sandbox inside QtWebEngine does not support root.
RUN chown ${NB_USER} ${HOME} ${HOME}/Slicer
USER ${NB_USER}

RUN mkdir /tmp/runtime-sliceruser
ENV XDG_RUNTIME_DIR=/tmp/runtime-sliceruser

################################################################################
# Set up remote desktop access - step 2/2

# Install websockify
# Copy rebind.so into websockify folder so websockify can find it
# Install Jupyter desktop (configures noVNC connection adds a new "Desktop" option in New menu in Jupyter)

# First upgrade pip
RUN /home/sliceruser/Slicer/bin/PythonSlicer -m pip install --upgrade pip

# Now install websockify and jupyter-server-proxy (fixed at tag v1.6.0)
RUN /home/sliceruser/Slicer/bin/PythonSlicer -m pip install --upgrade websockify && \
    cp /usr/lib/rebind.so /home/sliceruser/Slicer/lib/Python/lib/python3.6/site-packages/websockify/ && \
    /home/sliceruser/Slicer/bin/PythonSlicer -m pip install -e \
        git+https://github.com/lassoan/jupyter-desktop-server#egg=jupyter-desktop-server \
        git+https://github.com/jupyterhub/jupyter-server-proxy@v1.6.0#egg=jupyter-server-proxy

################################################################################
# Install Slicer extensions

COPY start-xorg.sh .
COPY install.sh .
RUN ./install.sh ${HOME}/Slicer/Slicer && \
    rm ${HOME}/install.sh

################################################################################
EXPOSE $VNCPORT $JUPYTERPORT
COPY run.sh .
ENTRYPOINT ["/home/sliceruser/run.sh"]

CMD ["sh", "-c", "./Slicer/bin/PythonSlicer -m jupyter notebook --port=$JUPYTERPORT --ip=0.0.0.0 --no-browser"]

################################################################################
# Install Slicer application startup script

COPY .slicerrc.py .

################################################################################
# Build-time metadata as defined at http://label-schema.org
ARG BUILD_DATE
ARG IMAGE
ARG VCS_REF
ARG VCS_URL
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name=$IMAGE \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url=$VCS_URL \
      org.label-schema.schema-version="1.0"
