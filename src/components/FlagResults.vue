<script setup lang="ts">
import { ref, computed } from 'vue'
import hljs from 'highlight.js/lib/core'
import json from 'highlight.js/lib/languages/json'

// Register JSON language
hljs.registerLanguage('json', json)

// Define props
const props = defineProps<{
  result?: any
  loading?: boolean
  error?: string | null
}>()

// Computed property to format the value
const formattedValue = computed(() => {
  if (!props.result) return ''
  return JSON.stringify(props.result.value, null, 2)
})

// Computed property to format the details
const formattedDetails = computed(() => {
  if (!props.result) return ''
  
  // Extract details excluding the value
  const { value, ...details } = props.result
  return JSON.stringify(details, null, 2)
})


</script>

<template>
  <div class="flag-results">
    <h2>Evaluation Results</h2>
    
    <div v-if="loading" class="loading">
      Evaluating flag...
    </div>
    
    <div v-else-if="error" class="error">
      Error: {{ error }}
    </div>
    
    <div v-else-if="result" class="results-content">
      <div class="result-section">
        <h3>Value</h3>
        <highlightjs :code="formattedValue" language="json"></highlightjs>
      </div>
      
      <div class="result-section">
        <h3>Details</h3>
        <highlightjs :code="formattedDetails" language="json"></highlightjs>
      </div>
    </div>
    
    <div v-else class="no-results">
      No results yet. Configure and evaluate a flag to see results here.
    </div>
  </div>
</template>
