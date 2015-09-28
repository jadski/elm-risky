
To run elm inside vagrant
=========================

Prepare a vagrant machine
-------------------------

You'll need this software installed locally:

 *virtualbox*
 
 *vagrant*

Create a new box named centos66

    :~ vagrant box add centos66 https://developer.nrel.gov/downloads/vagrant-boxes/CentOS-6.6-x86_64-v20150426.box

Provision your virtual machine, from repo top folder

    :~ cd vagrant
    :~ vagrant up

Run elm reactor
---------------

    :~ vagrant ssh
    :~ cd ~/game/game
    :~ elm-reactor

Play
----

Navigate to http://127.0.0.1:8000/
