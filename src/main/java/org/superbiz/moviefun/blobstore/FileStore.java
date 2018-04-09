package org.superbiz.moviefun.blobstore;

import java.io.*;
import java.util.Optional;


public class FileStore implements BlobStore {

    private String destDirectory=".";


    @Override
    public void put(Blob blob) throws IOException {

        /**
         *
         * public final String name;
         public final InputStream inputStream;
         public final String contentType;
         *
         */

        System.out.println("Adding new file");

        int ch;

        File destDir = new File(destDirectory + "/covers/" + blob.name);
        destDir.createNewFile();
        System.out.println("created file" + destDir);

        FileOutputStream outputStream = new FileOutputStream(destDir);

        BufferedInputStream bf =new BufferedInputStream(blob.inputStream);

        while ((ch = bf.read())!=-1){
            outputStream.write(ch);
        }

    }




    @Override
    public Optional<Blob> get(String name) throws IOException {

            File coverFile = new File(destDirectory + "/covers/" + name);
            System.out.println("Returned cover file = " + coverFile.toString() + " : " + coverFile.getPath() + " : " );
            //coverFilePath = Paths.get(getSystemResource(coverFile.toString()).toURI());


            byte[] fileContent = new byte[(int) coverFile.length()];
            FileInputStream fileInputStream = new FileInputStream(coverFile);
            fileInputStream.read(fileContent);

            Blob b = new Blob(coverFile.getName(),fileInputStream,coverFile.length()+"");

        Optional<Blob> optional = Optional.of(b);
        return optional;
    }

    @Override
    public void deleteAll() {
        // ...
    }



}