<template>
  <div>
    <h2 class="title">{{ name }}</h2>
    <Canvas v-bind="{ shader, name }" />
    <h3 class="headline">Code</h3>
    <code class="code">{{ shader }}</code>
  </div>
</template>

<style scoped>
.title {
  color: #111111;
  font-family: 'Roboto', sans-serif;
  font-weight: 900;
  font-size: 1.6rem;
  margin-top: 8px;
  margin-bottom: 16px;
}

.headline {
  color: #111111;
  font-family: 'Roboto', sans-serif;
  font-weight: 900;
  font-size: 1.4rem;
  margin-bottom: 8px;
}

#canvasBox {
  margin: 0 auto;
  width: 100%;
  max-width: 480px;
  height: 60vw;
  max-height: 360px;
  background: gray;
  border-radius: 4px;
  margin-bottom: 32px;
}

.code {
  background-color: #eeeeee;
  padding: 12px;
  font-size: 1rem;
  border-radius: 4px;
  display: block;
  color: #292929;
  white-space: pre-line;
  font-family: 'Anonymous Pro', monospace;
}
</style>

<script lang="ts">
import { Vue, Component, Prop } from 'vue-property-decorator'
import Canvas from '~/components/Canvas/Canvas.vue'

@Component({ components: { Canvas } })
export default class DetailView extends Vue {
  @Prop({ type: String, required: true }) readonly shader!: string
  @Prop({ type: String, required: true }) readonly name!: string
}
</script>
