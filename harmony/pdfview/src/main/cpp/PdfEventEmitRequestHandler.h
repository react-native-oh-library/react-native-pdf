#pragma once

#include "RNOH/ArkJS.h"
#include "RNOH/EventEmitRequestHandler.h"
#include "EventEmitters.h"

using namespace facebook;
namespace rnoh {

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
            auto  message = arkJs.getString(arkJs.getObjectProperty(ctx.payload, "message"));
            react::RNPDFPdfViewEventEmitter::OnChange event = {message};
            eventEmitter->onChange(event);
        };
    };
} 