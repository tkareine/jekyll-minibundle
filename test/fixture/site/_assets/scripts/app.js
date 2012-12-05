(function(root, dependency) {
  if (!dependency) throw new Error("missing dependency");
  root.app = {};
  console.log("loaded app");
})(window, window.dependency);
