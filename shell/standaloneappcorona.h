/*
 * Copyright 2014  Bhushan Shah <bhush94@gmail.com>
 * Copyright 2014 Marco Martin <notmart@gmail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License or (at your option) version 3 or any later version
 * accepted by the membership of KDE e.V. (or its successor approved
 * by the membership of KDE e.V.), which shall act as a proxy
 * defined in Section 14 of version 3 of the license.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>
 */

#ifndef SIMPLESHELLCORONA_H
#define SIMPLESHELLCORONA_H

#include <plasma/corona.h>
#include "desktopview.h"

class Activity;

namespace KActivities {
    class Consumer;
}

class StandaloneAppCorona : public Plasma::Corona
{
    Q_OBJECT

public:
    explicit StandaloneAppCorona(const QString &coronaPlugin, QObject * parent = 0);
    QRect screenGeometry(int id) const;

    void loadDefaultLayout();

    Plasma::Containment *createContainmentForActivity(const QString& activity, int screenNum);

    void insertActivity(const QString &id, Activity *activity);
    Plasma::Containment *addPanel(const QString &plugin);

public Q_SLOTS:
    void load();

    void currentActivityChanged(const QString &newActivity);
    void activityAdded(const QString &id);
    void activityRemoved(const QString &id);

protected Q_SLOTS:
    int screenForContainment(const Plasma::Containment *containment) const;

private:
    QString m_coronaPlugin;
    KActivities::Consumer *m_activityConsumer;
    KConfigGroup m_desktopDefaultsConfig;
    DesktopView *m_view;
    QHash<QString, Activity *> m_activities;
};

#endif
