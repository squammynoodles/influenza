import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  output: "standalone",
  // Enable if using images from external domains later
  // images: {
  //   remotePatterns: [
  //     {
  //       protocol: 'https',
  //       hostname: '*.railway.app',
  //     },
  //   ],
  // },
};

export default nextConfig;
