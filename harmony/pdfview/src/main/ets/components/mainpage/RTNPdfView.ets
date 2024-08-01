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
import Logger from '../../Logger';

import { PDFController, PDFView } from 'PDFView';
import { pdfService } from '@kit.PDFKit';
import { BusinessError } from '@kit.BasicServicesKit';
import common from '@ohos.app.ability.common';
import fs from '@ohos.file.fs';
import request from '@ohos.request';
import buffer from '@ohos.buffer';
import cryptoFramework from '@ohos.security.cryptoFramework';
import { LOAD_COMPLETE, ON_PROGRESS_CHANGE, PAGE_CHANGE, SCALE_CHANGED } from './types'

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

let context = getContext(this) as common.UIAbilityContext;
let filesDir = context.filesDir;

@Component
export struct RTNPdfView {
  ctx!: RNOHContext
  tag: number = 0
  @BuilderParam buildCustomComponent: (componentBuilderContext: ComponentBuilderContext) => void = this.emptyBuild;
  @State descriptor: PdfViewDescriptor = Object() as PdfViewDescriptor;
  @State pageIndex: number = 1;
  @State source: Resource | undefined = undefined;
  @State controllerStatus: boolean = false;
  private unregisterDescriptorChangesListener?: () => void = undefined;
  private cleanupCommandCallback?: () => void = undefined;
  private pdfController: PDFController = new PDFController();

  @Builder
  emptyBuild(ctx: ComponentBuilderContext) {
  }

  async doLoadHttpDocument(path: string): Promise<void> {
    try {
      const filePath: string = await this.downloadHttpFile(path);
      this.doLoadLocalDocument(filePath);
    } catch (e) {
      Logger.error(`[RTNPdfView]: fs accessSync: ${e}`);
    }
  }

  doLoadLocalDocument(filePath: string, isDelOriginFile: boolean = true): void {
    if (filePath) {
      this.pdfController.loadDocument(filePath)
        .then((res: pdfService.ParseResult) => {
          if (res === 0) {
            Logger.info(`[RTNPdfView]: loadDocument success`);
          }
        })
        .catch((e: Error) => {
          Logger.error(`[RTNPdfView]: loadDocument error: ${e.message}`);
        })
        .finally(() => {
          Logger.info(`[RTNPdfView]: isDelOriginFile is : ${isDelOriginFile}`)
          if (isDelOriginFile) {
            fs.unlink(filePath).then(() => {
              Logger.info(`[RTNPdfView]: originFile deleted`);
            })
          }
        })
    }
  }

  async downloadHttpFile(url: string): Promise<string> {
    const hashFileName: string = await this.processFileName(url);
    const fullFileName: string = filesDir + "/" + hashFileName + '.pdf';
    return new Promise((resolve, reject) => {
      // 获取应用文件路径
      try {
        Logger.info(`[RTNPdfView]: start downloadFile`);
        request.downloadFile(context, {
          url: url,
          filePath: fullFileName
        }).then((downloadTask: request.DownloadTask) => {
          downloadTask.on('complete', () => {
            Logger.info(`[RTNPdfView]: finish downloadFile`);
            resolve(fullFileName);
          })
        }).catch((err: BusinessError) => {
          reject("downloadFile failed" + err.message);
        });
      } catch (error) {
        let err: BusinessError = error as BusinessError;
        reject("downloadFile failed" + err.message);
      }
    });
  }

  async processFileName(originalURL: string): Promise<string> {
    return new Promise(async (resolve, reject) => {
      let mdAlgName = 'SHA256'; // 摘要算法名
      let md = cryptoFramework.createMd(mdAlgName);
      try {
        await md.update({ data: new Uint8Array(buffer.from(originalURL, 'utf-8').buffer) });
        let mdResult: cryptoFramework.DataBlob = await md.digest();
        const fileName: string = buffer.from(mdResult.data).toString('hex');
        Logger.info(`[RTNPdfView]: fileName: ${fileName}`);
        resolve(fileName);
      } catch (e) {
        reject("processFileName error");
      }
    });
  }

  async sendToSandBox(assetPath: string): Promise<string> {
    assetPath = assetPath!.replace("asset://", "assets/");
    Logger.info(`[RTNPdfView]: load pdf assetPath: ${assetPath}`);
    const newFileName: string = await this.processFileName(assetPath);

    // 需将pdf文档复制到沙箱路径下
    let context = getContext() as common.UIAbilityContext;
    let content = context.resourceManager.getRawFileContentSync(`${assetPath}`); //pdf_reference
    let dir = context.filesDir
    let fileFullPath = dir + '/' + newFileName + '.pdf';

    Logger.info(`[RTNPdfView]: load pdf filePath: ${fileFullPath}`);
    let res = fs.accessSync(fileFullPath);
    Logger.info(`[RTNPdfView]: fs accessSync: ${res}`);

    let fdSand = fs.openSync(fileFullPath, fs.OpenMode.WRITE_ONLY | fs.OpenMode.CREATE | fs.OpenMode.TRUNC);
    fs.writeSync(fdSand.fd, content.buffer);
    fs.closeSync(fdSand.fd);
    return fileFullPath;
  }

  async updateSource() {
    let src: string | undefined = this.descriptor.rawProps.path;
    Logger.info(`[RTNPdfView]: src is ${src}`);
    if (src) {
      if (src!.startsWith('http://') || src!.startsWith('https://')) {
        this.doLoadHttpDocument(src); // 适配加载在线文件
      } else {
        let isDeleteOriginFile: boolean = false;
        if (src!.startsWith('asset://')) { // 适配require('../assets/test.pdf')
          src = await this.sendToSandBox(src);
          isDeleteOriginFile = true;
        }
        this.doLoadLocalDocument(src, isDeleteOriginFile); // 适配本地其他目录，比如cache
      }
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
        message: `${PAGE_CHANGE}|${page}|${numberOfPages}`
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

  build() {
    RNViewBase({ ctx: this.ctx, tag: this.tag }) {
      if (this.descriptor.rawProps.path) {
        PDFView(
          {
            controller: this.pdfController,
            pageLayout: pdfService.PageLayout.LAYOUT_SINGLE,
            isContinuous: true,
            pageFit: pdfService.PageFit.FIT_WIDTH
          }
        )
      }
    }
  }
}