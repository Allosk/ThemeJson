#pragma once

#include <QObject>
#include <QJsonObject>
#include <QVariantMap>

class PaletteModel : public QObject
{
    Q_OBJECT
    
    Q_PROPERTY(QVariantList colors READ colors NOTIFY themeColorsChanged)
    Q_PROPERTY(bool loaded READ isLoaded NOTIFY loadedChanged)

public:
    explicit PaletteModel(QObject *parent = nullptr);


    QVariantList colors() const;
    bool isLoaded() const;

    Q_INVOKABLE bool hasColor(const QString &theme, const QString &colorName) const;
    Q_INVOKABLE void setColor(const QString &theme, const QString &colorName, const QString &hexValue);
    Q_INVOKABLE void save();
    Q_INVOKABLE bool loadFromFile(const QString filePath);

signals:
    void themeColorsChanged();
    void loadedChanged();
    
private:
    QString m_filePath;
    QJsonObject m_data;


    void saveJson();
};
