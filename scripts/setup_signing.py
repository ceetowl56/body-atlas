"""Adds release signing to the generated Android project.
Run once in android/app after `flutter create`. Safe to run twice.
Reads android/key.properties (created by the build workflow).
"""
import os
import re
import sys

KTS = "android/app/build.gradle.kts"
GROOVY = "android/app/build.gradle"


def patch_kts(s):
    if "keystoreProperties" in s:
        return s, "already patched"
    header = "import java.util.Properties\nimport java.io.FileInputStream\n\n"
    props = (
        "val keystoreProperties = Properties()\n"
        'val keystorePropertiesFile = rootProject.file("key.properties")\n'
        "if (keystorePropertiesFile.exists()) {\n"
        "    keystoreProperties.load(FileInputStream(keystorePropertiesFile))\n"
        "}\n\n"
    )
    s = re.sub(r"^android \{", lambda m: props + "android {", s, count=1, flags=re.M)

    def add_signing(m):
        i = m.group(1)
        return (
            f"{i}signingConfigs {{\n"
            f'{i}    create("release") {{\n'
            f'{i}        keyAlias = keystoreProperties["keyAlias"] as String?\n'
            f'{i}        keyPassword = keystoreProperties["keyPassword"] as String?\n'
            f'{i}        storeFile = keystoreProperties["storeFile"]?.let {{ file(it as String) }}\n'
            f'{i}        storePassword = keystoreProperties["storePassword"] as String?\n'
            f"{i}    }}\n"
            f"{i}}}\n\n"
            f"{i}buildTypes {{"
        )

    s = re.sub(r"^([ \t]*)buildTypes \{", add_signing, s, count=1, flags=re.M)
    s = s.replace('signingConfigs.getByName("debug")', 'signingConfigs.getByName("release")')
    return header + s, "patched"


def patch_groovy(s):
    if "keystoreProperties" in s:
        return s, "already patched"
    props = (
        "def keystoreProperties = new Properties()\n"
        "def keystorePropertiesFile = rootProject.file('key.properties')\n"
        "if (keystorePropertiesFile.exists()) {\n"
        "    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))\n"
        "}\n\n"
    )
    s = re.sub(r"^android \{", lambda m: props + "android {", s, count=1, flags=re.M)

    def add_signing(m):
        i = m.group(1)
        return (
            f"{i}signingConfigs {{\n"
            f"{i}    release {{\n"
            f"{i}        keyAlias keystoreProperties['keyAlias']\n"
            f"{i}        keyPassword keystoreProperties['keyPassword']\n"
            f"{i}        storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null\n"
            f"{i}        storePassword keystoreProperties['storePassword']\n"
            f"{i}    }}\n"
            f"{i}}}\n\n"
            f"{i}buildTypes {{"
        )

    s = re.sub(r"^([ \t]*)buildTypes \{", add_signing, s, count=1, flags=re.M)
    s = s.replace("signingConfigs.debug", "signingConfigs.release")
    return s, "patched"


def main():
    for path, fn in ((KTS, patch_kts), (GROOVY, patch_groovy)):
        if os.path.exists(path):
            with open(path) as f:
                original = f.read()
            patched, status = fn(original)
            if "signingConfigs" not in patched or ("release" not in patched):
                print(f"WARNING: could not patch {path}; edit signing by hand.")
                sys.exit(1)
            if patched != original:
                with open(path, "w") as f:
                    f.write(patched)
            print(f"{path}: {status}")
            return
    print("No android/app/build.gradle(.kts) found. Run flutter create first.")
    sys.exit(1)


main()
