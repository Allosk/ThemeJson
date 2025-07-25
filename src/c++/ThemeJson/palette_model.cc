#include <ThemeJson/palette_model.h>
#include <QFile>
#include <QJsonDocument>
#include <QDebug>
#include <QFileInfo>
#include <qdebug.h>

PaletteModel::PaletteModel(QObject *parent) : QObject(parent)
{
}

QVariantList PaletteModel::colors() const {
    QVariantList list;

    auto colorsObject = m_data["colors"].toObject();
    QJsonObject dark = colorsObject["dark"].toObject();
    QJsonObject light = colorsObject["light"].toObject();

    for (const QString &key : dark.keys()) {
        QVariantMap entry;
        entry["name"] = key;
        entry["dark"] = dark[key].toString();
        entry["light"] = light.value(key).toString();
        list.append(entry);
    }

    return list;
}

void PaletteModel::setColor(const QString &theme, const QString &colorName, const QString &hexValue) {
    if (!m_data["colors"].toObject().contains(theme))
        return;

    QJsonObject colors = m_data["colors"].toObject();
    QJsonObject themeObj = colors[theme].toObject();
    themeObj[colorName] = hexValue;
    colors[theme] = themeObj;
    m_data["colors"] = colors;

    emit themeColorsChanged();
}

void PaletteModel::save() {
    saveJson();
}

bool PaletteModel::loadFromFile(const QString filePath)
{
    QString localPath = QUrl(filePath).toLocalFile();

    qDebug()<<"Путь"<<localPath;

    QFile file(localPath);

    if (!file.exists()) {
        qWarning() << "File does not exist:" << localPath;
        return false;
    }

    if (!file.open(QIODevice::ReadOnly)) {
        qWarning() << "Failed to open file:" << localPath;
        return false;
    }

    QByteArray data = file.readAll();
    file.close();

    QJsonDocument doc = QJsonDocument::fromJson(data);
    if (!doc.isObject()) {
        qWarning() << "Invalid JSON";
        return false;
    }

    m_data = doc.object();
    m_filePath = localPath;

    emit loadedChanged();
    emit themeColorsChanged();
    return true;
}

void PaletteModel::saveJson() {
    QFile file(m_filePath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        qWarning() << "Failed to write JSON file";
        return;
    }
    QJsonDocument doc(m_data);
    file.write(doc.toJson(QJsonDocument::Indented));
    file.close();
}

bool PaletteModel::hasColor(const QString &theme, const QString &colorName) const {
    if (!m_data.contains("colors"))
        return false;

    QJsonObject colors = m_data["colors"].toObject();

    if (!colors.contains(theme))
        return false;

    QJsonObject themeObj = colors[theme].toObject();
    return themeObj.contains(colorName);
}

bool PaletteModel::isLoaded() const {
    return !m_filePath.isEmpty();
}
