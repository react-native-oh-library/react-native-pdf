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

import { Descriptor, ComponentBuilderContext, ViewRawProps, ViewBaseProps } from '@rnoh/react-native-openharmony';
import { RNOHContext, RNViewBase } from '@rnoh/react-native-openharmony';
import web_webview from '@ohos.web.webview';
import Logger from '../../Logger';
import {ASSET, HIDE_TOOLBAR, HTTP, HTTPS, LOAD_COMPLETE, ON_PROGRESS_CHANGE, PAGE_CHANGE, SCALE_CHANGED,}from './types'
export const PDF_VIEW_TYPE: string = "RTNPdfView";

export interface PdfViewState {}

export interface PdfViewRawProps extends ViewRawProps {
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
}

export type PdfViewDescriptor = Descriptor<'RTNPdfView', ViewBaseProps, PdfViewState, PdfViewRawProps>

@Component
export struct RTNPdfView {
  webviewController: web_webview.WebviewController = new web_webview.WebviewController();
  ctx!: RNOHContext
  tag: number = 0
  @BuilderParam buildCustomComponent: (componentBuilderContext: ComponentBuilderContext) => void = this.emptyBuild;
  @State descriptor: PdfViewDescriptor = Object() as PdfViewDescriptor;
  @State pageIndex: number = 1;
  @State source: Resource | undefined = undefined;
  @State controllerStatus: boolean = false;
  private unregisterDescriptorChangesListener?: () => void = undefined;
  private cleanupCommandCallback?: () => void = undefined;

  @Builder
  emptyBuild(ctx: ComponentBuilderContext) {
  }

  updateSource() {
    let src = this.descriptor.rawProps.path;
    if (src!.startsWith(`${ASSET}://`)) {
      this.source = $rawfile(src!.replace(`${ASSET}://`, `${ASSET}/`));
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
    if (this.controllerStatus) {
      this.webviewController.removeCache(true);
    }
  }

  loadComplete(numberOfPages: number) {
    Logger.info("[RNOH]:enter loadComplete");
    this.ctx.rnInstance.emitComponentEvent(
      this.descriptor.tag,
      PDF_VIEW_TYPE,
      {
        message: `${LOAD_COMPLETE}|${numberOfPages}|${this.width}|${this.height}`
      }
    );
  }

  onPageChanged(page: number, numberOfPages: number) {
    Logger.info("[RNOH]:enter pageChanged");
    this.ctx.rnInstance.emitComponentEvent(
      this.descriptor.tag,
      PDF_VIEW_TYPE,
      {
        message:`${PAGE_CHANGE}|${page}|${numberOfPages}`
      }
    );
  }

  onScaleChanged() {
    Logger.info("[RNOH]:enter scaleChanged");
    this.ctx.rnInstance.emitComponentEvent(
      this.descriptor.tag,
      PDF_VIEW_TYPE,
      {
        message: `${SCALE_CHANGED}|${this.scale}`
      }
    );
  }

  onChange() {
    Logger.info("[RNOH]:onChange not support");
    this.ctx.rnInstance.emitComponentEvent(
      this.descriptor.tag,
      PDF_VIEW_TYPE,
      {
        message: ON_PROGRESS_CHANGE
      }
    );
  }

  private getSrc(): string {
    if (this.source) {
      return this.isHttpUrl(`${this.source}`) ? `${this.source}${HIDE_TOOLBAR}` : `${this.source}`
    }
    return this.isHttpUrl(`${this.descriptor.rawProps.path}`) ?
      `${this.descriptor.rawProps.path}${HIDE_TOOLBAR}` : `${this.descriptor.rawProps.path}`
  }

  private isHttpUrl(url: string | undefined): boolean {
    if (url) {
      return [HTTP, HTTPS].some((item: string) => url.startsWith(item))
    }
    return false
  }

  build() {
    RNViewBase({ ctx: this.ctx, tag: this.tag }) {
      if (this.descriptor.rawProps.path) {
        Web({ src: this.getSrc(), controller: this.webviewController })
          .domStorageAccess(true)
          .javaScriptAccess(true)
          .width('100%')
          .height('100%')
          .onControllerAttached(() => {
            this.controllerStatus = true
          })
      }
    }
  }
}