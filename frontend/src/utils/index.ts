export const objectCleaner = (obj: object) => {
  for (const propName in obj) {
    if (
      obj[propName as keyof object] === null ||
      obj[propName as keyof object] === undefined ||
      obj[propName as keyof object] === ""
    ) {
      delete obj[propName as keyof object];
    }
  }
  return obj;
};
