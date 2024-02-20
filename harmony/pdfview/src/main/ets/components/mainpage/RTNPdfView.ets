import { Descriptor, ComponentBuilderContext, ViewBaseProps, Tag } from 'rnoh';
import { RNComponentFactory, RNOHContext, RNViewBase } from 'rnoh';
import web_webview from '@ohos.web.webview';


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
  @State descriptor: PdfViewDescriptor = {} as PdfViewDescriptor
  private unregisterDescriptorChangesListener?: () => void = undefined
  private cleanupCommandCallback?: () => void = undefined
  @State pageIndex: number = 0
  @State source:Resource|undefined = undefined

  @Builder
  emptyBuild(ctx: ComponentBuilderContext) {
  }

  updateSource(){
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
        console.log(`[RNOH]: CommandCallback,command: ${command}`)
        console.log(`[RNOH]: CommandCallback,selectedPage: ${args[0]}`)
        this.pageIndex = args[0] as number
      });
  }

  aboutToDisappear() {
    this.cleanupCommandCallback?.();
    this.unregisterDescriptorChangesListener?.()
  }

  build() {
    RNViewBase({ ctx: this.ctx, tag: this.tag }) {
      if (this.descriptor.props.path){
        Web({ src: this.source ? this.source : this.descriptor.props.path, controller: this.webviewController })
          .domStorageAccess(true)
          .javaScriptAccess(true)
          .width("100%")
          .height("100%")
      }
    }
  }
}