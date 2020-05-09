<template>
  <div class="row">
    <DetailView v-bind:shader="source" v-bind:name="name" />
  </div>
</template>

<style>
#code {
  white-space: pre-wrap;
}
.row {
  margin: 0 16px;
}
</style>

<script lang="ts">
import DetailView from '~/components/DetailView/DetailView.vue'
import { Vue, Component, Prop } from 'vue-property-decorator'

const asyncData = async ({ params }: any) => {
  const metaData = require('../../shaders/meta.json')
  const jsonData = require(`../../shaders/${params.name}.json`)
  return { source: jsonData.body, title: 'haga', name: params.name }
}

export default {
  asyncData,
  components: { DetailView }
}
</script>
