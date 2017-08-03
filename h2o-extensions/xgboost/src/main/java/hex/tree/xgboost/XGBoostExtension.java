package hex.tree.xgboost;

import ml.dmlc.xgboost4j.java.NativeLibLoader;
import water.AbstractH2OExtension;
import water.util.Log;

import java.io.IOException;

/**
 * XGBoost Extension
 *
 * This is responsible for early initialization of
 * XGBoost per cluster node. The registration
 * of XGBoost REST API requires thix extension
 * to be enabled.
 */
public class XGBoostExtension extends AbstractH2OExtension {

  private static String XGBOOST_MIN_REQUIREMENTS =
          "Xgboost (enabled GPUs) needs: \n"
                  + "  - CUDA 8.0\n"
                  + "XGboost (minimal version) needs: \n"
                  + "  - no req\n";

  public static String NAME = "XGBoost";

  @Override
  public String getExtensionName() {
    return NAME;
  }

  @Override
  public boolean isEnabled() {
    // Check if some native library was loaded
    try {
      String libName = NativeLibLoader.getLoadedLibraryName();
      if (libName != null) {
        Log.info("Found XGBoost backend with library: " + libName);
        return true;
      } else {
        Log.warn("Cannot get XGBoost backend!" + XGBOOST_MIN_REQUIREMENTS);
        return false;
      }
    } catch (IOException e) {
      // Ups no lib loaded or load failed
      Log.warn("Cannot initialize XGBoost backend! " + XGBOOST_MIN_REQUIREMENTS, e);
      return false;
    }
  }
}