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


################################################################################
# these go after installs to avoid trivial invalidation
ENV VNCPORT=49053
ENV JUPYTERPORT=8888
ENV DISPLAY=:10







################################################################################
EXPOSE $VNCPORT 
#ENTRYPOINT ["/home/sliceruser/run.sh"]
ENTRYPOINT ["sh", "/home/sliceruser/nb/start"]
#CMD ["sh", "-c", "./Slicer/bin/PythonSlicer -m jupyter notebook --port=8888 --ip=0.0.0.0 --no-browser"]
CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--no-browser"]

################################################################################
# Install Slicer application startup script

#COPY .slicerrc.py .

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
