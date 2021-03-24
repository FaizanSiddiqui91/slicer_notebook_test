FROM lassoan/slicer-notebook:2020-05-15-89b6bb5
COPY --chown=sliceruser . ${HOME}/nb
WORKDIR ${HOME}/nb


################################################################################
# launch jupyter
# Prevent apt-get from prompting for keyboard choice
#  https://superuser.com/questions/1356914/how-to-install-xserver-xorg-in-unattended-mode







################################################################################


################################################################################


################################################################################

################################################################################

################################################################################


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


