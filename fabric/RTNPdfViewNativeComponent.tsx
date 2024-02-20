import { ComponentType } from "react";
import type { HostComponent,ViewProps } from "react-native";
import { BubblingEventHandler, Float, Int32 } from "react-native/Libraries/Types/CodegenTypes";
import codegenNativeCommands from "react-native/Libraries/Utilities/codegenNativeCommands";
import codegenNativeComponent from "react-native/Libraries/Utilities/codegenNativeComponent";

type ChangeEvent = {
  message: string,
};

export interface NativeProps extends ViewProps {
  path?: string,
  page?: Int32,
  scale?: Float,
  minScale?: Float,
  maxScale?: Float,
  horizontal?: boolean,
  enablePaging?: boolean,
  enableRTL?: boolean,
  enableAnnotationRendering?: boolean,
  showsHorizontalScrollIndicator?: boolean,
  showsVerticalScrollIndicator?: boolean,
  enableAntialiasing?: boolean,
  fitPolicy?: Int32,
  spacing?: Int32,
  password?: string,
  onChange?: BubblingEventHandler<ChangeEvent>,
  singlePage?: boolean,
}

interface NativeCommands {
  setNativePage: (
    viewRef: React.ElementRef<ComponentType>,
    page: Int32,
  ) => void;
}

export const Commands: NativeCommands = codegenNativeCommands<NativeCommands>({
  supportedCommands: ['setNativePage'],
});

export default codegenNativeComponent<NativeProps>(
  "RTNPdfView"
) as HostComponent<NativeProps>;
