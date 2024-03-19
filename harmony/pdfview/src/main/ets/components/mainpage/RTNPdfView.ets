/*
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

import { Descriptor, ComponentBuilderContext, ViewBaseProps, Tag } from 'rnoh';
import { RNComponentFactory, RNOHContext, RNViewBase } from 'rnoh';
import web_webview from '@ohos.web.webview';
import Logger from '../../Logger';

export const PDF_VIEW_TYPE: string = "RTNPdfView"

export interface PdfViewProps extends ViewBaseProps {
  path?: string,
  page?: number,
  scale?: number,
  minScale?: number,
  maxScale?: number,
  horizontal?: boolean,
  enablePaging?: boolean,
  enableRTL?: boolean,
  enableAnnotationRendering?: boolean,
  showsHorizontalScrollIndicator?: boolean,
  showsVerticalScrollIndicator?: boolean,
  enableAntialiasing?: boolean,
  fitPolicy?: number,
  spacing?: number,
  password?: string,
  singlePage?: boolean,
};

export type PdfViewDescriptor = Descriptor<'RTNPdfView', PdfViewProps>

@Component
export struct RTNPdfView {
  webviewController: web_webview.WebviewController = new web_webview.WebviewController();
  ctx!: RNOHContext
  tag: number = 0
  @BuilderParam buildCustomComponent: (componentBuilderContext: ComponentBuilderContext) => void = this.emptyBuild;
  @State descriptor: PdfViewDescriptor = {} as PdfViewDescriptor;
  private unregisterDescriptorChangesListener?: () => void = undefined;
  private cleanupCommandCallback?: () => void = undefined;
  @State pageIndex: number = 1;
  @State source: Resource | undefined = undefined;

  @Builder
  emptyBuild(ctx: ComponentBuilderContext) {
  }

  updateSource() {
    let src = this.descriptor.props.path;
    if (src!.startsWith('asset://')) {
      this.source = $rawfile(src!.replace("asset://", "assets/"));
    }
  }

  aboutToAppear() {
    this.descriptor = this.ctx.descriptorRegistry.getDescriptor<PdfViewDescriptor>(this.tag)
    this.updateSource();
    this.unregisterDescriptorChangesListener = this.ctx.descriptorRegistry.subscribeToDescriptorChanges(this.tag,
      (newDescriptor) => {
        this.descriptor = (newDescriptor as PdfViewDescriptor)
        this.updateSource();
      }
    )

    this.cleanupCommandCallback = this.ctx.componentCommandReceiver.registerCommandCallback(
      this.tag,
      (command, args: (boolean | number)[]) => {
        Logger.info(`[RNOH]: HarmonyOS does not support,command:  ${command}, arg: ${args[0]}`);
        this.pageIndex = args[0] as number;
      });
  }

  aboutToDisappear() {
    this.cleanupCommandCallback?.();
    this.unregisterDescriptorChangesListener?.();
    this.webviewController.removeCache(true);
  }

  loadComplete(numberOfPages: number) {
    Logger.info("[RNOH]:enter loadComplete");
    this.ctx.rnInstance.emitComponentEvent(
      this.descriptor.tag,
      PDF_VIEW_TYPE,
      {
        message: 'loadComplete|' + numberOfPages + '|' + this.width + '|' + this.height
      }
    );
  }

  onPageChanged(page: number, numberOfPages: number) {
    Logger.info("[RNOH]:enter pageChanged");
    this.ctx.rnInstance.emitComponentEvent(
      this.descriptor.tag,
      PDF_VIEW_TYPE,
      {
        message: 'pageChanged|' + page + '|' + numberOfPages
      }
    );
  }

  onScaleChanged() {
    Logger.info("[RNOH]:enter scaleChanged");
    this.ctx.rnInstance.emitComponentEvent(
      this.descriptor.tag,
      PDF_VIEW_TYPE,
      {
        message: 'scaleChanged|' + this.scale
      }
    );
  }

  onChange() {
    Logger.info("[RNOH]:onChange not support");
    this.ctx.rnInstance.emitComponentEvent(
      this.descriptor.tag,
      PDF_VIEW_TYPE,
      {
        message: 'onProgressChange'
      }
    );
  }

  build() {
    RNViewBase({ ctx: this.ctx, tag: this.tag }) {
      if (this.descriptor.props.path) {
        Web({ src: this.source ? this.source : this.descriptor.props.path, controller: this.webviewController })
          .domStorageAccess(true)
          .javaScriptAccess(true)
          .width('100%')
          .height('100%')
      }
    }
  }
}