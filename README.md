# submarine - ein Scrum-Backlog-Tool

submarine ist ein Scrum-Tool für Backlogs. Es unterstützt Sie bei der Planung ihrer Sprints. Mehr Infos zu submarine gibt's unter www.scrum-backlog.de.

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

### Daten pflegen

Es gibt leider zur Zeit noch kein User Interface zum Anlegen von Projekten.
Deshalb müssen diese über ein Tool, zum Beispiel mit dem SQLite Database Browser, angelegt werden (http://sqlitebrowser.sourceforge.net/). Eine andere Möglichkeit ist das Anlegen über die Rails-Konsole. Dazu im submarine-Verzeichnis 'rails c' eingeben. Mit dem folgenden Befehl kann ein neues Projekt angelegt werden:
Project.create(name: „Projektname“)
submarine verwendet Bilder. Dafür müssen im Ordner app/assets/images für jedes Projekt zwei png-Dateien abgelegt werden:
* projektname_heavy.png
* projektname_light.png

## Geplante Features

* Benutzeroberfläche zur Projektverwaltung
* Drucken des Sprint Backlogs
