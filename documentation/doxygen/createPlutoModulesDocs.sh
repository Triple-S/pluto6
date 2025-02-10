#!/bin/bash

rm -f PlutoModules.md

#HEADER_FILES=$(find $DOXYGEN_SOURCE_DIRECTORY -type f -name '*.h' -and -not -name '*LinkDef.h')

#while read HEADER_FILE; do
#    OBJECT_NAME=$(basename $HEADER_FILE)
#    printf "\\\file %s\n" "$OBJECT_NAME" >> PlutoModules.md
#done <<< $HEADER_FILES

for ROOTMAP_FILE in $(find ${PLUTODIR}/lib -type f,l -name '*.rootmap' | tr '\n' ' '); do
    MODULE_NAME=$(basename -s '.rootmap' ${ROOTMAP_FILE} | tail -c +4)

    printf "\\defgroup Module%s %s Library\n\\\brief The Pluto %s library\n" "${MODULE_NAME}" "${MODULE_NAME}" "${MODULE_NAME}" >> PlutoModules.md

    while read -r ROOTMAP_LINE; do
        OBJECT_NAME=""

        if [[ "${ROOTMAP_LINE}" == "class"* ]]; then
            OBJECT_NAME=$(tail -c +7 <<< ${ROOTMAP_LINE})
        elif [[ "${ROOTMAP_LINE}" == "namespace"* ]]; then
            OBJECT_NAME=$(tail -c +11 <<< ${ROOTMAP_LINE})
        elif [[ "${ROOTMAP_LINE}" == "enum"* ]]; then
            OBJECT_NAME=$(tail -c +6 <<< ${ROOTMAP_LINE})
        elif [[ "${ROOTMAP_LINE}" == "var"* ]]; then 
            OBJECT_NAME=$(tail -c +5 <<< ${ROOTMAP_LINE})
        elif [[ "${ROOTMAP_LINE}" == "typedef"* ]]; then
            OBJECT_NAME=$(tail -c +9 <<< ${ROOTMAP_LINE})
        fi

        if [[ ${OBJECT_NAME} != "" ]]; then
            printf "\\%s\n\\ingroup Module%s\nThe Pluto %s.\n" "${ROOTMAP_LINE}" "${MODULE_NAME}" "${ROOTMAP_LINE}" >> PlutoModules.md
        fi
    done < ${ROOTMAP_FILE}
done
