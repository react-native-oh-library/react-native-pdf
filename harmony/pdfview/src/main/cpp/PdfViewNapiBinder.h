//
// Created on 2024/1/16.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#ifndef HARMONY_PDFVIEWNAPIBINDER_H
#define HARMONY_PDFVIEWNAPIBINDER_H

#include "RNOHCorePackage/ComponentBinders/ViewComponentNapiBinder.h"
#include "Props.h"

namespace rnoh {

    class PdfViewNapiBinder : public ViewComponentNapiBinder {
    public:
        napi_value createProps(napi_env env, facebook::react::ShadowView const shadowView) override {
            napi_value napiViewProps = ViewComponentNapiBinder::createProps(env, shadowView);
            if (auto props = std::dynamic_pointer_cast<const facebook::react::RNPDFPdfViewProps>(shadowView.props)) {
                return ArkJS(env)
                    .getObjectBuilder(napiViewProps)
                    .addProperty("path", props->path)
                    .addProperty("page", props->page)
                    .addProperty("scale", props->scale)
                    .addProperty("minScale", props->minScale)
                    .addProperty("maxScale", props->maxScale)
                    .addProperty("horizontal", props->horizontal)
                    .addProperty("enablePaging", props->enablePaging)
                    .addProperty("enableRTL", props->enableRTL)
                    .addProperty("enableAnnotationRendering", props->enableAnnotationRendering)
                    .addProperty("showsHorizontalScrollIndicator", props->showsHorizontalScrollIndicator)
                    .addProperty("showsVerticalScrollIndicator", props->showsVerticalScrollIndicator)
                    .addProperty("enableAntialiasing", props->enableAntialiasing)
                    .addProperty("fitPolicy", props->fitPolicy)
                    .addProperty("spacing", props->spacing)
                    .addProperty("password", props->password)
                    .addProperty("singlePage", props->singlePage)
                    .build();
            }
            return napiViewProps;
        };
    };
} // namespace rnoh


#endif //HARMONY_PDFVIEWNAPIBINDER_H
