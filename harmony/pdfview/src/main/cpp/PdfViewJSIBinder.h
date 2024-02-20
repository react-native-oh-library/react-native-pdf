//
// Created on 2024/1/16.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#ifndef HARMONY_PDFVIEWJSIBINDER_H
#define HARMONY_PDFVIEWJSIBINDER_H

#include "RNOHCorePackage/ComponentBinders/ViewComponentJSIBinder.h"

namespace rnoh {

    class PdfViewJSIBinder : public ViewComponentJSIBinder {
        facebook::jsi::Object createNativeProps(facebook::jsi::Runtime &rt) override {
            auto object = ViewComponentJSIBinder::createNativeProps(rt);
            object.setProperty(rt, "path", "string");
            object.setProperty(rt, "page", "int");
            object.setProperty(rt, "scale", "float");
            object.setProperty(rt, "minScale", "float");
            object.setProperty(rt, "maxScale", "float");
            object.setProperty(rt, "horizontal", "boolean");
            object.setProperty(rt, "enablePaging", "boolean");
            object.setProperty(rt, "enableRTL", "boolean");
            object.setProperty(rt, "enableAnnotationRendering", "boolean");
            object.setProperty(rt, "showsHorizontalScrollIndicator", "boolean");
            object.setProperty(rt, "showsVerticalScrollIndicator", "boolean");
            object.setProperty(rt, "enableAntialiasing", "boolean");
            object.setProperty(rt, "fitPolicy", "int");
            object.setProperty(rt, "spacing", "int");
            object.setProperty(rt, "password", "string");
            object.setProperty(rt, "singlePage", "boolean");
            return object;
        }
    };
} // namespace rnoh


#endif //HARMONY_PDFVIEWJSIBINDER_H
