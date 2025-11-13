<script setup lang="ts">
import { ref, onMounted, watch } from "vue";
import { v4 as uuidv4 } from "uuid";
// @ts-expect-error
import CodeEditor from "simple-code-editor";

// Define props
const props = defineProps<{
  proxyUrl?: string;
  apiKey?: string | null;
}>();

// Define emits
const emit = defineEmits<{
  (e: "update:proxyUrl", value: string): void;
  (e: "update:apiKey", value: string | null): void;
  (e: "evaluate", data: any): void;
}>();

// Form data
const formData = ref({
  flagName: "",
  flagType: "bool" as "bool" | "string" | "int" | "float" | "object",
  targetingKey: "",
  context: "{}",
});

// Error states
const contextError = ref<string | null>(null);
const defaultValueError = ref<string | null>(null);

// Initialize targeting key on component mount
onMounted(() => {
  formData.value.targetingKey = uuidv4();
});

const validateAndParseContext = (): any => {
  if (formData.value.context.trim() !== "") {
    try {
      return JSON.parse(formData.value.context);
    } catch (e) {
      contextError.value = "Invalid JSON format in context attributes";
      return;
    }
  }
  return {};
};

// Handle form submission
const handleSubmit = () => {
  // Reset errors
  contextError.value = null;
  defaultValueError.value = null;

  // Validate and parse the context JSON
  const contextObj = validateAndParseContext();

  if (contextError.value || defaultValueError.value) {
    return;
  }

  emit("evaluate", {
    flagName: formData.value.flagName,
    flagType: formData.value.flagType,
    targetingKey: formData.value.targetingKey,
    context: contextObj,
  });
};

// Expose the handleSubmit method to parent components
defineExpose({
  handleSubmit,
});
</script>

<template>
  <div class="flag-input">
    <h2>Flag Configuration</h2>

    <div class="form-group">
      <label for="proxyUrl">Proxy URL:</label>
      <input
        id="proxyUrl"
        type="text"
        :value="props.proxyUrl"
        @input="
          $emit('update:proxyUrl', ($event.target as HTMLInputElement).value)
        "
        placeholder="http://localhost:1031"
      />
    </div>

    <div class="form-group">
      <label for="apiKey">API Key (optional):</label>
      <input
        id="apiKey"
        type="password"
        :value="props.apiKey || ''"
        @input="
          $emit('update:apiKey', ($event.target as HTMLInputElement).value || null)
        "
        placeholder="Enter API key (if required)"
      />
    </div>

    <div class="form-group">
      <label for="flagName">Flag Name:</label>
      <input
        id="flagName"
        type="text"
        v-model="formData.flagName"
        placeholder="Enter flag name"
        required
      />
    </div>

    <div class="form-group">
      <label for="flagType">Flag Type:</label>
      <select id="flagType" v-model="formData.flagType">
        <option value="bool">Boolean</option>
        <option value="string">String</option>
        <option value="int">Integer</option>
        <option value="float">Float</option>
        <option value="object">Object</option>
      </select>
    </div>

    <div class="form-group">
      <label for="targetingKey">Targeting Key:</label>
      <input
        id="targetingKey"
        type="text"
        v-model="formData.targetingKey"
        placeholder="Enter targeting key"
      />
      <button
        type="button"
        @click="formData.targetingKey = uuidv4()"
        class="generate-btn"
      >
        Generate UUID
      </button>
    </div>

    <div class="form-group">
      <label for="context">Context Attributes (JSON):</label>
      <CodeEditor
        v-model="formData.context"
        :languages="[['json', 'JSON']]"
        :header="false"
        theme="github"
        padding="10px"
        width="100%"
        font-size="13px"
        border-radius="4px"
      />
      <div v-if="contextError" class="error-message">
        {{ contextError }}
      </div>
    </div>

    <button @click="handleSubmit" class="evaluate-btn">Evaluate Flag</button>
    <p class="shortcut-hint">Tip: Press Ctrl/Cmd + Enter to evaluate flag</p>
  </div>
</template>
