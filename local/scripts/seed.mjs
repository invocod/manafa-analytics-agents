// Rebuild local/data/db.json from the seed files and the repo. `npm run seed` overwrites local page data.
import { seedIfMissing } from "./store.mjs";
seedIfMissing(process.argv.includes("--force"));
