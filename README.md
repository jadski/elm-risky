
*To run elm inside vagrant*

**Prepare a vagrant machine**

You'll need this software installed locally:

    virtualbox
    vagrant

Create a new box named scientific6

  vagrant box add scientific6 http://lyte.id.au/vagrant/sl6-64-lyte.box

Provision your virtual machine

  cd vagrant
  vagrant up

**Run elm reactor**

  vagrant ssh
  cd ~/game
  elm-reactor

**Play**

Navigate to http://127.0.0.1:8000/
