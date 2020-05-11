declare module 'highlight.js/lib/core' {
  export function registerLanguage(name: string, obj: any): void
  export function highlightBlock(dom: any): void
}
declare module 'highlight.js/lib/languages/*' {}
declare module 'highlight.js/styles/*' {}
