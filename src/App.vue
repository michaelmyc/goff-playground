<script setup lang="ts">
import { ref, watch, onMounted, onUnmounted } from "vue";
import { OpenFeature } from "@openfeature/web-sdk";
import { GoFeatureFlagWebProvider } from "@openfeature/go-feature-flag-web-provider";
import FlagInput from "./components/FlagInput.vue";
import FlagResults from "./components/FlagResults.vue";

// Global state
const proxyUrl = ref("http://localhost:1031");
const evaluationResult = ref<any>(null);
const isLoading = ref(false);
const error = ref<string | null>(null);
const providerInitialized = ref(false);

// Ref to hold the FlagInput component instance
const flagInputRef = ref<InstanceType<typeof FlagInput> | null>(null);

// Keyboard event handler for Ctrl+Enter/Cmd+Enter
const handleKeyDown = (event: KeyboardEvent) => {
  if ((event.ctrlKey || event.metaKey) && event.key === "Enter") {
    event.preventDefault();
    // Call the handleSubmit method from FlagInput component
    if (flagInputRef.value) {
      flagInputRef.value.handleSubmit();
    }
  }
};

// Add event listener when component is mounted
onMounted(() => {
  document.addEventListener("keydown", handleKeyDown);
});

// Remove event listener when component is unmounted
onUnmounted(() => {
  document.removeEventListener("keydown", handleKeyDown);
});

// Initialize the GO Feature Flag provider when proxy URL changes
watch(
  proxyUrl,
  async (newUrl) => {
    try {
      isLoading.value = true;
      error.value = null;

      // Create the GO Feature Flag provider
      const provider = new GoFeatureFlagWebProvider({
        endpoint: newUrl,
      });

      // Set the provider
      await OpenFeature.setProviderAndWait(provider);
      providerInitialized.value = true;
    } catch (err) {
      error.value =
        err instanceof Error ? err.message : "Failed to initialize provider";
      providerInitialized.value = false;
    } finally {
      isLoading.value = false;
    }
  },
  { immediate: true },
);

// Function to handle flag evaluation
const evaluateFlag = async (flagData: any) => {
  if (!providerInitialized.value) {
    error.value = "Provider not initialized. Please check the proxy URL.";
    return;
  }

  isLoading.value = true;
  error.value = null;

  try {
    // Get the client
    const client = OpenFeature.getClient();

    // Set up evaluation context
    await OpenFeature.setContext({
      targetingKey: flagData.targetingKey,
      ...flagData.context,
    });

    // Evaluate the flag based on its type
    let result: any;
    let details: any;

    switch (flagData.flagType) {
      case "boolean":
        details = client.getBooleanDetails(
          flagData.flagName,
          flagData.defaultValue,
        );
        result = {
          value: details.value,
          reason: details.reason,
          variant: details.variant,
          flagMetadata: details.flagMetadata,
        };
        break;
      case "string":
        details = client.getStringDetails(
          flagData.flagName,
          flagData.defaultValue,
        );
        result = {
          value: details.value,
          reason: details.reason,
          variant: details.variant,
          flagMetadata: details.flagMetadata,
        };
        break;
      case "number":
        details = client.getNumberDetails(
          flagData.flagName,
          flagData.defaultValue,
        );
        result = {
          value: details.value,
          reason: details.reason,
          variant: details.variant,
          flagMetadata: details.flagMetadata,
        };
        break;
      case "object":
        details = client.getObjectDetails(
          flagData.flagName,
          flagData.defaultValue,
        );
        result = {
          value: details.value,
          reason: details.reason,
          variant: details.variant,
          flagMetadata: details.flagMetadata,
        };
        break;
      default:
        throw new Error(`Unsupported flag type: ${flagData.flagType}`);
    }

    evaluationResult.value = {
      ...result,
      flagName: flagData.flagName,
      flagType: flagData.flagType,
      targetingKey: flagData.targetingKey,
      context: flagData.context,
    };
  } catch (err) {
    error.value =
      err instanceof Error ? err.message : "An unknown error occurred";
  } finally {
    isLoading.value = false;
  }
};
</script>

<template>
  <div class="app-container">
    <header>
      <h1>Go Feature Flag Playground</h1>
    </header>

    <div class="main-content">
      <div class="section">
        <FlagInput
          ref="flagInputRef"
          :proxy-url="proxyUrl"
          @update:proxy-url="proxyUrl = $event"
          @evaluate="evaluateFlag"
        />
      </div>

      <div class="section">
        <FlagResults
          :result="evaluationResult"
          :loading="isLoading"
          :error="error"
        />
      </div>
    </div>
  </div>
</template>
