module.exports = {
  mode: "jit",
  purge: [
    "./js/**/*.js", 
    "../lib/*_web/**/*.*ex",
    "../../lib/*_web/**/*.*ex"
  ],
  darkMode: false, // false or 'media' or 'class'
  theme: {
    extend: {
      fontFamily: {
        sans: ["Quicksand", "sans-serif"]
      }
    },
  },
  variants: {},
  plugins: [],
};
