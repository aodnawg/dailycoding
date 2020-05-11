<template>
  <div class="content">
    <h2 class="title">{{ name }}</h2>
    <Canvas v-bind="{ shader, name }" />
    <div class="flex-headilne">
      <h3 class="headline">Code</h3>
      <a v-bind:href="githubLink" target="_blank">
        see on Github
        <fa :icon="faGithub" />
      </a>
    </div>
    <pre ref="codeRef" class="glsl"><code class="code">{{ shader }}</code></pre>
  </div>
</template>

<style scoped lang="scss">
.content {
  color: #111111;
  a {
    color: #111111;
  }
}

.title {
  color: #111111;
  font-family: 'Roboto', sans-serif;
  font-weight: 900;
  font-size: 2.4rem;
  margin-top: 8px;
  margin-bottom: 16px;
}

.flex-headilne {
  display: flex;
  justify-content: space-between;
}

.headline {
  color: #111111;
  font-family: 'Roboto', sans-serif;
  font-weight: 900;
  font-size: 1.8rem;
  margin-bottom: 8px;
}

#canvasBox {
  margin: 0 auto 64px;
  width: 100%;
  max-width: 480px;
  height: 60vw;
  max-height: 360px;
  background: gray;
  border-radius: 4px;
}

.code {
  padding: 12px;
  font-size: 1rem !important;
  border-radius: 4px !important;
  display: block;
  font-family: 'Anonymous Pro', monospace;
}
</style>

<script lang="ts">
import { Vue, Component, Prop } from 'vue-property-decorator'
import Canvas from '~/components/Canvas/Canvas.vue'
import { faGithub } from '@fortawesome/free-brands-svg-icons'
import hljs from 'highlight.js/lib/core'
import glsl from 'highlight.js/lib/languages/glsl'

@Component({ components: { Canvas } })
export default class DetailView extends Vue {
  @Prop({ type: String, required: true }) readonly shader!: string
  @Prop({ type: String, required: true }) readonly name!: string

  mounted() {
    hljs.registerLanguage('glsl', glsl)
    hljs.highlightBlock(this.$refs.codeRef as HTMLDivElement)
  }

  get faGithub() {
    return faGithub
  }

  get githubLink() {
    return `https://github.com/aodnawg/dailycoding/blob/master/shaders/${this.name}.glsl`
  }
}
</script>
