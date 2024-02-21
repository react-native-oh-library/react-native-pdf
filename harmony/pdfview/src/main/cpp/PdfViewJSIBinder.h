/**
 * MIT License
 *
 * Copyright (C) 2024 Huawei Device Co., Ltd.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

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
