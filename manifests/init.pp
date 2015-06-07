# Puppet Stages
stage {
    'users':       before => Stage['folders'];
    'folders':     before => Stage['updates'];
    'updates':     before => Stage['packages'];
    'packages':    before => Stage['composer'];
    'composer':    before => Stage['configure'];
    'configure':   before => Stage['services'];
    'services':    before => Stage['main'];
}

class users {
    group { "www-data":
        ensure => "present",
     }
}

class folders {
    file { ['/var/www']:
        ensure => 'directory',
        owner => 'www-data',
        group => 'www-data',
        mode => 0755
    }
}

class updates {
    exec { "aptitude-update":
        command => "/usr/bin/aptitude update -y -q",
        timeout => 0
    }
}

class packages {
    package {[
            "git",
            "curl",
            "apache2",
            "mysql-server",
            "php5",
            "php5-mysql",
            "php5-gd",
            "php5-curl",
            "php5-mcrypt",
            "php5-cli"
            ]:
        ensure => "present",
    }
}

class composer {
    exec {
        "get-composer":
            command => '/usr/bin/sudo curl -sS https://getcomposer.org/installer | php',
            unless => '/usr/bin/which composer';

        "set-composer":
            command => '/usr/bin/sudo mv composer.phar /usr/local/bin/composer',
            unless => '/usr/bin/which composer',
            require => Exec['get-composer'];

        "composer-dir":
            command => '/bin/mkdir -p ~/.composer',
            unless => '/bin/ls ~/.composer';

        "github-api-conf":
            command => '/usr/bin/sudo cp /var/www/manifests/composer.json ~/.composer/config.json',
            onlyif => '/bin/ls /var/www/manifests/composer.json',
            unless => '/bin/ls ~/.composer/config.json',
            require => Exec['composer-dir'];
    }
}

class configure {
    exec {
        "clear-apache-conf":
            command => '/usr/bin/sudo rm /etc/apache2/sites-enabled/000-default.conf',
            onlyif => '/bin/ls /etc/apache2/sites-enabled/000-default.conf';

        "link-apache-conf":
            command => '/usr/bin/sudo cp /var/www/manifests/vagrant.conf /etc/apache2/sites-enabled/vagrant.conf',
            unless => '/bin/ls /etc/apache2/sites-enabled/vagrant.conf';

        "clear-index":
            command => '/bin/rm /var/www/index.html',
            onlyif => '/bin/ls /var/www/index.html';

        "clear-html":
            command => '/bin/rm -r /var/www/html',
            onlyif => '/bin/ls /var/www/html';

        "apache-rewrite":
            command => '/usr/bin/sudo a2enmod rewrite';

        "enable-php-mcrypt":
            command => '/usr/bin/sudo php5enmod mcrypt';

        "mysql-bind-address":
            command => '/usr/bin/sudo cp /vagrant/manifests/bind.cnf /etc/mysql/conf.d/bind.cnf',
            unless => '/bin/ls /etc/mysql/conf.d/bind.cnf';

        "mysql-privilege":
            command => '/usr/bin/mysql -uroot -h 127.0.0.1 -e \'GRANT ALL PRIVILEGES ON sg.* TO "vagrant"@"%" IDENTIFIED BY "vagrant"; FLUSH PRIVILEGES;\'';

        "mysql-create-database":
            command => '/usr/bin/mysql -uvagrant -pvagrant -h 127.0.0.1 -e \'CREATE DATABASE sg;\'',
            unless => '/usr/bin/mysql -uroot -h 127.0.0.1 sg';
    }
}

class services {
    exec {
        "apache-restart":
            command => '/usr/bin/sudo service apache2 restart';
        "mysql-restart":
            command => '/usr/bin/sudo service mysql restart';
    }
}

class {
    users:       stage => "users";
    folders:     stage => "folders";
    updates:     stage => "updates";
    packages:    stage => "packages";
    composer:    stage => "composer";
    configure:   stage => "configure";
    services:    stage => "services";
}
