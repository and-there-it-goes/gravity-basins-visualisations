<style>
span.katex-html {
  text-align: left;
  & > * {
    margin-bottom: 0.5lh;
  }
}
</style>
$$
s = \text{position} \\
v = \text{velocity} \\
v_\theta = \text{angle of }v \\
\min{r} = \text{distance to nearest body} \\
t = \text{time} \\
{\int_{0}^{T}{{...}\ dt}} = \text{accumulated over }t\text{ (whole simulation)} \\
\|x\| = \text{length of vector }x \\
\Delta x = \text{change in }x\text{ over }t \\
\ \\
Lab = \text{CIELAB colour space (}L\text{*}a\text{*}b\text{*)} \\
ab\text{ refers to a 2D vector of }(a\text{*},b\text{*}) \\
{\sim}\ \text{means ``proportional to".}\\
\ \\
0.\hspace{1em} RGB = \left( \text{nearest body} \right) \\
1.\hspace{1em} Lab;\ L \sim \int_{0}^{T} \left( \Delta v_\theta \right) dt \\
2.\hspace{1em} Lab;\ ab = \frac{s_0 - s_\text{final}}{\| {s_0 - s_\text{final}} \|} \\
3.\hspace{1em} RGB;\ 25G + 5B = \left( \text{\# nearest body changes} \right) \\
4.\hspace{1em} Lab;\ ab \sim \int_{0}^{T} \left( \Delta v \right) dt \\
5.\hspace{1em} Lab;\ ab \sim \int_{0}^{T} \left( \Delta v \times \min{r} \right) dt;\ L \sim \|ab\| \\
6.\hspace{1em} Lab;\ L \sim ab \sim \int_{0}^{T} \left( \| {\Delta v} \| \right) dt \\
7.\hspace{1em} Lab;\ L \sim ab \sim \int_{0}^{T} \left( \| {\Delta v} \| \times \min{r} \right) dt \\
8.\hspace{1em} Lab;\ L \sim \int_{0}^{T} \left( \| {\Delta s} \| \right) dt \\
9.\hspace{1em} Lab;\ L \sim \frac{\int_{0}^{T} \left( \| {\Delta s} \| \right) dt}{\| {s_0 - s_\text{final}} \|} \\
10.\hspace{1em} Lab;\ L \sim \int_{0}^{T} \left( \| {\Delta s} \| \times \min{r} \right) dt \\
11.\hspace{1em} Lab;\ L \sim \frac{\int_{0}^{T} \left( \| {\Delta s} \| \times \min{r} \right) dt}{\| {s_0 - s_\text{final}} \|} \\
\ \\
\text{\fbox {Q} key cycle order:} \left[ 0, 3, 1, 6, 7, 8, 10, 9, 11, 2, 4, 5 \right]
$$