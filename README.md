# Cutoff

KDE Plasma's Application Launcher, but just the list.
<p align="center">
  <img width="49%" alt="Standard Cutoff" src="https://github.com/user-attachments/assets/7c328455-5241-4258-a8e7-f709fdd8c8ca" />
  <img width="49%" alt="Pop-up Cutoff" src="https://github.com/user-attachments/assets/a4f6376f-d5da-4f42-af03-2f28b31f4248" />
</p>

> [!NOTE]
> A fork of [Kickoff](https://invent.kde.org/plasma/plasma-desktop/-/tree/master/applets/kickoff) by Martin Gräßlin and Mikel Johnson.<br>
> *Requires KDE Plasma 6.0+.*

- Just a single alphabetical list with Favourites pinned to the top.
- KRunner search bar.
- Resizable standard and pop-up views.


## Get Started

Download the latest `.plasmoid` from [Releases](https://github.com/galib-i/cutoff/releases/latest) and install it [manually](https://userbase.kde.org/Plasma/Installing_Plasmoids#:~:text=panel%20as%20usual.-,Installing%20from%20local%20file,-Select%20Add%20Widgets) or with `kpackagetool6`:

```
kpackagetool6 -t Plasma/Applet -i com.github.galib.cutoff.plasmoid
```

Or, clone this repository and use the included install script:

```bash
git clone https://github.com/galib-i/cutoff
cd cutoff
./install.sh install local      # ~/.local/share/plasma/plasmoids, no sudo
./install.sh install global     # /usr/share/plasma/plasmoids, with sudo
```

Once installed, either: 
- Right-click your current menu and select *Show alternatives...*.
- Right-click the desktop or a panel, select *Add Widgets*, and search for "Cutoff".

To update or remove it:

```bash
./install.sh update local      # or ./install.sh update global, with sudo
./install.sh uninstall local   # or ./install.sh uninstall global, with sudo
```
> [!TIP]
> You may need to restart Plasma (log out/in, or run `systemctl restart --user plasma-plasmashell.service`) to see changes.

## Configuration

Right-click the widget and choose *Configure Cutoff…*:
<p align="center">
  <img width="500" alt="Cutoff configurations" src="https://github.com/user-attachments/assets/a249dce0-f599-4ca8-a117-cc7625dd8780" />
</p>

##
*Licensed under the [GPLv2 or later](LICENSE), inheriting from the original source code.*
