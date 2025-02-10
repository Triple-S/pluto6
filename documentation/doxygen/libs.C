#include "TString.h"
#include "TInterpreter.h"
#include "TSystem.h"
#include "TObjArray.h"
#include "TObjString.h"

void libs(TString classname) {
    TString libname;

    // Find in which library classname sits
    classname.ReplaceAll("_1", ":");
    classname.ReplaceAll("_01", " ");
    int i = classname.Index("_3");
    if (i > 0) classname.Remove(i, classname.Length() - i);

    libname = gInterpreter->GetClassSharedLibs(classname.Data(), kFALSE);
    if (libname.IsNull())
        return;

    // More than one Library was found, try to identify the correct one using the rootmap files
    if (libname.CountChar(' ') > 0) {
        TString libs = gSystem->GetFromPipe(Form("grep -l '%s$' ${ROOTSYS}/lib/*.rootmap ${PLUTODIR}/lib/*.rootmap | cut -f 1 -d '.' | rev | cut -f 1 -d '/' | rev", classname.Data()));

        if (libs.IsNull())
            libname = libname(0, libname.First(' '));
        else {
            TObjArray* toa = libs.Tokenize("\n");
            for (Int_t i = 0; i < toa->GetEntries(); ++i) {
                TObjString* tos = (TObjString*) toa->At(i);
                if (libname.Contains(tos->GetString())) {
                    libname = tos->GetString() + ".so";
                    break;
                }
            }
            delete toa;

            if (libname.Contains(" ")) {
                if (libs.Contains("\n"))
                    libname = libs(0, libs.First('\n')) + ".so";
                else
                    libname = libs + ".so";
            }
        }
    }

    if (libname.IsNull())
        return;

    printf("mainlib=%s", libname.Data());
}
