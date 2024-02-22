import express, { Express, Request, Response, NextFunction } from 'express';
import bearerToken from 'express-bearer-token';
import axios from 'axios';
import { PrismaClient } from '@prisma/client'

import content from '@/content';

const app = express();
app.use(express.json());
app.use(bearerToken());

export interface UserRequset extends Request {
    userId?: Number
}

const kakaoLoginMiddleWare = async function (req: UserRequset, res: Response, next: NextFunction) {
    const token = req.token;
    const prisma = new PrismaClient()

    if (!token) {
        res.status(401).send('unAuthorized')
        return
    }

    const kakaoLoginResponse = await axios.get('https://kapi.kakao.com/v2/user/me',
        {
            headers: {
                "Authorization": `Bearer ${token}`,
                "Content-Type": "application/x-www-form-urlencoded;charset=utf-8"
            }
        })

    if (kakaoLoginResponse.status == 200) {
        const user = await prisma.user.findUnique({
            where: {
                id: Number(kakaoLoginResponse.data.id)
            }
        })

        if (!user) {
            await prisma.user.create({ data: { id: Number(kakaoLoginResponse.data.id) } })
        }

        req.userId = Number(kakaoLoginResponse.data.id)

        next()
    } else {
        res.status(401)
        return
    }
}
app.use(kakaoLoginMiddleWare)

app.use("/content", content)

app.get('/', (req: Request, res: Response) => {
    res.send('Typescript + Node.js + Express Server');
});

const port = 3000;
app.listen(port, () => {
    console.log(`[server]: Server is running at <http://localhost:${port}>`);
});