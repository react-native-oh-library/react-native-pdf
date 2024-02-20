//
// Created on 2024/1/16.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#ifndef HARMONY_PDFVIEWPACKAGE_H
#define HARMONY_PDFVIEWPACKAGE_H

#include "RNOH/Package.h"
#include "ComponentDescriptors.h"
#include "PdfViewJSIBinder.h"
#include "PdfViewNapiBinder.h"
#include "PdfEventEmitRequestHandler.h"

namespace rnoh {

    class PdfViewPackage : public Package {
    public:
        PdfViewPackage(Package::Context ctx) : Package(ctx) {}

        std::vector<facebook::react::ComponentDescriptorProvider> createComponentDescriptorProviders() override {
            return {facebook::react::concreteComponentDescriptorProvider<
                facebook::react::RNPDFPdfViewComponentDescriptor>()};
        }

        ComponentNapiBinderByString createComponentNapiBinderByName() override {
            return {{"RTNPdfView", std::make_shared<PdfViewNapiBinder>()}};
        }

        ComponentJSIBinderByString createComponentJSIBinderByName() override {
            return {{"RTNPdfView", std::make_shared<PdfViewJSIBinder>()}};
        }

        EventEmitRequestHandlers createEventEmitRequestHandlers() override {
            return {std::make_shared<PdfEventEmitRequestHandler>()};
        }
    };
} // namespace rnoh


#endif //HARMONY_CENTEREDTEXTPACKAGE_H
