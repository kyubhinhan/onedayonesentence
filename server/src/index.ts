import express, { Express, Request, Response } from 'express';
import content from '@/content';

const app = express();
const port = 3000;

app.use(express.json());
app.use("/content", content)

app.get('/', (req: Request, res: Response) => {
    res.send('Typescript + Node.js + Express Server');
});

app.listen(port, () => {
    console.log(`[server]: Server is running at <http://localhost:${port}>`);
});