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

#pragma once

#include "RNOH/ArkJS.h"
#include "RNOH/EventEmitRequestHandler.h"
#include "EventEmitters.h"

using namespace facebook;
namespace rnoh {

enum class PdfViewEventType { 
    PDF_ONCHANGE = 0,
    PDF_ONSCALECHANGED = 1,
    PDF_ONLOADCOMPLETE = 2,
    PDF_ONLOADPROGRESS = 3,
    PDF_ONERROR = 4
};

PdfViewEventType getPdfEventType(ArkJS &arkJs, napi_value eventObject)
{
    auto eventType = arkJs.getString(arkJs.getObjectProperty(eventObject, "type"));
    if (eventType == "onChange") {
        return PdfViewEventType::PDF_ONCHANGE;
    } else if (eventType == "onScaleChanged") {
        return PdfViewEventType::PDF_ONSCALECHANGED;
    } else if (eventType == "onLoadComplete") {
        return PdfViewEventType::PDF_ONLOADCOMPLETE;
    } else if (eventType == "onLoadProgress") {
        return PdfViewEventType::PDF_ONLOADPROGRESS;
    } else if (eventType == "onError") {
        return PdfViewEventType::PDF_ONERROR;
    } {
        throw std::runtime_error("Unknown Page event type");
    }
}

    class PdfEventEmitRequestHandler : public EventEmitRequestHandler {
    public:
        void handleEvent(EventEmitRequestHandler::Context const &ctx) override {
            if (ctx.eventName != "RTNPdfView") {
                return;
            }
            ArkJS arkJs(ctx.env);
            auto eventEmitter = ctx.shadowViewRegistry->getEventEmitter<react::RNPDFPdfViewEventEmitter>(ctx.tag);
            if (eventEmitter == nullptr) {
                return;
            }
        
            switch (getPdfEventType(arkJs, ctx.payload)) {
                case PdfViewEventType::PDF_ONCHANGE: {
                    auto  message = arkJs.getString(arkJs.getObjectProperty(ctx.payload, "message"));
                    react::RNPDFPdfViewEventEmitter::OnChange event = {message};
                    eventEmitter->onChange(event);
                    break;
                }
                case PdfViewEventType::PDF_ONSCALECHANGED: {
                    auto  scale = arkJs.getDouble(arkJs.getObjectProperty(ctx.payload, "scale"));
                    react::RNPDFPdfViewEventEmitter::OnScaleChanged event1 = {scale};
                    eventEmitter->onScaleChanged(event1);
                    break;
                }
                case PdfViewEventType::PDF_ONLOADCOMPLETE: {
                    auto  scale = arkJs.getDouble(arkJs.getObjectProperty(ctx.payload, "scale"));
                    react::RNPDFPdfViewEventEmitter::OnLoadValue event2 = {scale};
                    eventEmitter->onLoadComplete(event2);
                    break;
                }
                case PdfViewEventType::PDF_ONLOADPROGRESS: {
                    auto  percent = arkJs.getDouble(arkJs.getObjectProperty(ctx.payload, "percent"));
                    react::RNPDFPdfViewEventEmitter::OnProgressValue event2 = {percent};
                    eventEmitter->onLoadProgress(event2);
                    break;
                }
                case PdfViewEventType::PDF_ONERROR: {
                    auto  message = arkJs.getString(arkJs.getObjectProperty(ctx.payload, "message"));
                    react::RNPDFPdfViewEventEmitter::OnErrorValue event2 = {message};
                    eventEmitter->onError(event2);
                    break;
                }
                default:
                    break;
            }
        };
    };
} 