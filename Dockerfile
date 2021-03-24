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


################################################################################
# these go after installs to avoid trivial invalidation
ENV VNCPORT=49053
#ENV JUPYTERPORT=8888
ENV DISPLAY=:10



# Prevent git error:
#   fatal: unable to access 'https://github.com/novnc/websockify/': server certificate verification failed. CAfile: none CRLfile: none






################################################################################
EXPOSE $VNCPORT $JUPYTERPORT.
ENTRYPOINT ["/home/sliceruser/run.sh"]

#CMD ["sh", "-c", "./Slicer/bin/PythonSlicer -m jupyter notebook --port=8888 --ip=0.0.0.0 --no-browser"]
CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--no-browser"]

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
