module.exports = {
  mode: "jit",
  purge: [
    "./js/**/*.js", 
    "../lib/*_web/**/*.*ex"
  ],
  darkMode: false, // false or 'media' or 'class'
  theme: {
    extend: {
    },
  },
  variants: {},
  plugins: [],
};
