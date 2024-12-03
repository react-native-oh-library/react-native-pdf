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

#include "Props.h"
#include <react/renderer/core/PropsParserContext.h>
#include <react/renderer/core/propsConversions.h>

namespace facebook {
namespace react {

RNPDFPdfViewProps::RNPDFPdfViewProps(
    const PropsParserContext &context,
    const RNPDFPdfViewProps &sourceProps,
    const RawProps &rawProps): ViewProps(context, sourceProps, rawProps),

    source(convertRawProp(context, rawProps, "source", sourceProps.source, {})),
    path(convertRawProp(context, rawProps, "path", sourceProps.path, {})),
    page(convertRawProp(context, rawProps, "page", sourceProps.page, {0})),
    scale(convertRawProp(context, rawProps, "scale", sourceProps.scale, {0.0})),
    minScale(convertRawProp(context, rawProps, "minScale", sourceProps.minScale, {0.0})),
    maxScale(convertRawProp(context, rawProps, "maxScale", sourceProps.maxScale, {0.0})),
    horizontal(convertRawProp(context, rawProps, "horizontal", sourceProps.horizontal, {false})),
    enablePaging(convertRawProp(context, rawProps, "enablePaging", sourceProps.enablePaging, {false})),
    enableRTL(convertRawProp(context, rawProps, "enableRTL", sourceProps.enableRTL, {false})),
    enableAnnotationRendering(convertRawProp(context, rawProps, "enableAnnotationRendering", sourceProps.enableAnnotationRendering, {false})),
    showsHorizontalScrollIndicator(convertRawProp(context, rawProps, "showsHorizontalScrollIndicator", sourceProps.showsHorizontalScrollIndicator, {false})),
    showsVerticalScrollIndicator(convertRawProp(context, rawProps, "showsVerticalScrollIndicator", sourceProps.showsVerticalScrollIndicator, {false})),
    enableAntialiasing(convertRawProp(context, rawProps, "enableAntialiasing", sourceProps.enableAntialiasing, {false})),
    fitPolicy(convertRawProp(context, rawProps, "fitPolicy", sourceProps.fitPolicy, {0})),
    spacing(convertRawProp(context, rawProps, "spacing", sourceProps.spacing, {0})),
    password(convertRawProp(context, rawProps, "password", sourceProps.password, {})),
    singlePage(convertRawProp(context, rawProps, "singlePage", sourceProps.singlePage, {false}))
      {}

} // namespace react
} // namespace facebook
