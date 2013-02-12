# Emma Social VM

This is the VM for `emmasocial`.

## Setup

You know the routine:

```bash
vagrant up
```

This will provision a `lucid64` box, installing:

* MySQL
* Redis
* Python 2.7
* `pip` and `virtualenv`
* The `emmasocial` Django app, including all its dependencies

It will also:

* Create a `emmasocial` database
* Run `syncdb` on the database
* Allow connections from the host to the database (`mysql -u root -h 127.0.0.1 emmasocial`)
* Auto-activate the `emmasocial` virtualenv on login to the VM

It should all _just work_.

### Extra bits of setup

On your local machine, create a hosts entry for the app:

```bash
sudo cat >> /etc/hosts
192.168.33.42      emmasocial.local          # Vagrant VM
192.168.33.42      emmasocial.int            # Vagrant VM
```

And create an SSH config entry:

```bash
cat >> ~/.ssh/config
Host emmasocial
  HostName emmasocial.local
  User vagrant
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no
  PasswordAuthentication no
  IdentityFile ~/.vagrant.d/insecure_private_key
  IdentitiesOnly yes
```

Then, you should be able to SSH into the VM via `ssh emmasocial`.

## Running the app

```bash
vagrant ssh
cd emmasocial/src/
sudo ./manage.py runserver 0.0.0.0:80
```

Then, point your browser at [http://emmasocial.local/](http://emmasocial.local/).