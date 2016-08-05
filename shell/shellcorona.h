/*
 *   Copyright 2008 Aaron Seigo <aseigo@kde.org>
 *   Copyright 2013 Sebastian Kügler <sebas@kde.org>
 *   Copyright 2013 Ivan Cukic <ivan.cukic@kde.org>
 *   Copyright 2013 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#ifndef SHELLCORONA_H
#define SHELLCORONA_H

#include "plasma/corona.h"

#include <QSet>
#include <QTimer>
#include <QDBusVariant>
#include <QDBusContext>

#include <KPackage/Package>

class DesktopView;
class PanelView;
class QMenu;
class QScreen;
class ScreenPool;

namespace KActivities
{
    class Controller;
} // namespace KActivities

namespace KDeclarative
{
    class QmlObject;
} // namespace KDeclarative

namespace KScreen {
    class Output;
} // namespace KScreen

namespace Plasma
{
    class Applet;
} // namespace Plasma

namespace KWayland
{
    namespace Client
    {
        class PlasmaShell;
    }
}

class ShellCorona : public Plasma::Corona, QDBusContext
{
    Q_OBJECT
    Q_PROPERTY(QString shell READ shell WRITE setShell)
    Q_PROPERTY(int numScreens READ numScreens)
    Q_CLASSINFO("D-Bus Interface", "org.kde.PlasmaShell")

public:
    explicit ShellCorona(QObject *parent = 0);
    ~ShellCorona() override;

    KPackage::Package lookAndFeelPackage();

    /**
     * Where to save global configuration that doesn't have anything to do with the scene (e.g. views)
     */
    KSharedConfig::Ptr applicationConfig();

    int numScreens() const override;
    Q_INVOKABLE QRect screenGeometry(int id) const override;
    Q_INVOKABLE QRegion availableScreenRegion(int id) const override;
    Q_INVOKABLE QRect availableScreenRect(int id) const override;

    Q_INVOKABLE QStringList availableActivities() const;

    PanelView *panelView(Plasma::Containment *containment) const;

    // This one is a bit of an hack but are just for desktop scripting
    void insertActivity(const QString &id, const QString &plugin);

    Plasma::Containment *setContainmentTypeForScreen(int screen, const QString &plugin);

    void removeDesktop(DesktopView *desktopView);

    /**
     * @returns a new containment associated with the specified @p activity and @p screen.
     */
    Plasma::Containment *createContainmentForActivity(const QString &activity, int screenNum);

    KWayland::Client::PlasmaShell *waylandPlasmaShellInterface() const;


    ScreenPool *screenPool() const;

    QList<int> screenIds() const;

    QString defaultContainmentPlugin() const;


protected:
    bool eventFilter(QObject *watched, QEvent *event) override;

public Q_SLOTS:
    /**
     * Request saving applicationConfig on disk, it's event compressed, not immediate
     */
    void requestApplicationConfigSync();

    /**
     * Sets the shell that the corona should display
     */
    void setShell(const QString &shell);

    /**
     * Gets the currently shown shell
     */
    QString shell() const;

    ///DBUS methods
    void toggleDashboard();
    void setDashboardShown(bool show);
    void loadInteractiveConsole();
    void showInteractiveConsole();
    void loadScriptInInteractiveConsole(const QString &script);
    void showInteractiveKWinConsole();
    void loadKWinScriptInInteractiveConsole(const QString &script);
    void toggleActivityManager();
    void evaluateScript(const QString &string);

    Plasma::Containment *addPanel(const QString &plugin);

    void nextActivity();
    void previousActivity();
    void stopCurrentActivity();

protected Q_SLOTS:
    /**
     * Loads the layout and performs the needed checks
     */
    void load();

    /**
     * Unloads everything
     */
    void unload();

    /**
     * Loads the default (system wide) layout for this user
     **/
    void loadDefaultLayout() override;

    /**
     * Execute any update script
     */
    void processUpdateScripts();

    int screenForContainment(const Plasma::Containment *containment) const override;

    void showAlternativesForApplet(Plasma::Applet *applet);

private Q_SLOTS:
    void createWaitingPanels();
    void handleContainmentAdded(Plasma::Containment *c);
    void toggleWidgetExplorer();
    void syncAppConfig();
    void checkActivities();
    void currentActivityChanged(const QString &newActivity);
    void activityAdded(const QString &id);
    void activityRemoved(const QString &id);
    void checkAddPanelAction(const QStringList &sycocaChanges = QStringList());
    void addPanel();
    void addPanel(QAction *action);
    void populateAddPanelsMenu();

    void addOutput(QScreen* screen);
    void primaryOutputChanged();

    void panelContainmentDestroyed(QObject* cont);
    void desktopContainmentDestroyed(QObject*);
    void showOpenGLNotCompatibleWarning();
    void alternativesVisibilityChanged(bool visible);
    void interactiveConsoleVisibilityChanged(bool visible);
    void screenRemoved(QScreen* screen);

private:
    void updateStruts();
    bool isOutputRedundant(QScreen* screen) const;
    void reconsiderOutputs();
    QList<PanelView *> panelsForScreen(QScreen *screen) const;
    DesktopView* desktopForScreen(QScreen *screen) const;
    void setupWaylandIntegration();
    void executeSetupPlasmoidScript(Plasma::Containment *containment, Plasma::Applet *applet);

#ifndef NDEBUG
    void screenInvariants() const;
#endif

    void insertContainment(const QString &activity, int screenNum, Plasma::Containment *containment);

    ScreenPool *m_screenPool;
    QString m_shell;
    KActivities::Controller *m_activityController;
    //map from screen number to desktop view, qmap as order is important
    QMap<int, DesktopView *> m_desktopViewforId;
    QHash<const Plasma::Containment *, PanelView *> m_panelViews;
    KConfigGroup m_desktopDefaultsConfig;
    KConfigGroup m_lnfDefaultsConfig;
    QList<Plasma::Containment *> m_waitingPanels;
    QHash<QString, QString> m_activityContainmentPlugins;
    QHash<QString, QSet<Plasma::Containment *> > m_desktopContainments;
    QAction *m_addPanelAction;
    QMenu *m_addPanelsMenu;
    KPackage::Package m_lookAndFeelPackage;
    QSet<QScreen*> m_redundantOutputs;
    QList<KDeclarative::QmlObject *> m_alternativesObjects;
    KDeclarative::QmlObject *m_interactiveConsole;

    QTimer m_waitingPanelsTimer;
    QTimer m_appConfigSyncTimer;
    QTimer m_reconsiderOutputsTimer;

    KWayland::Client::PlasmaShell *m_waylandPlasmaShell;
};

#endif // SHELLCORONA_H


