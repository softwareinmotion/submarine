# submarine - ein Scrum-Backlog-Tool

submarine ist ein Scrum-Tool für Backlogs. Es unterstützt Sie bei der Planung ihrer Sprints.

## Installation

submarine basiert auf Ruby und dem Webframework RubyOnRails. Ruby kann unter http://www.ruby-lang.org/de/downloads heruntergeladen werden und entsprechend der dortigen Anleitung installiert werden.

Nach dem Klonen von submarine muss in das eben erstellte Verzeichnis gewechselt werden.

Bei einer Erst-Installation von Ruby muss zunächst der Gem-Manager Bundler über folgenden Kommandozeilen-Befehl installiert werden:
    
    gem install bundler

Anschließend können die notwendigen Ruby-Gems und die von submarine verwendete SQLite-Datenbank über folgende Kommandos installiert werden:

    bundle install
    rake db:migrate

Damit ist die Installation von submarine abgeschlossen.

## Benutzung

### Server starten

submarine kann mit 'rails s' gestartet werden und mit Strg + C beendet werden.


## Features

### Vorhandene Features

* Benutzeroberfläche zur Aufgabenverwaltung
* Benutzeroberfläche zur Projektverwaltung
* die Aufgabenverwaltung beinhaltet die Richtlinien nach ISO 9001

### Geplante Features

* Kommentieren der Aufgaben im Sprint - Backlog
